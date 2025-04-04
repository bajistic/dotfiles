this is the plugin script:
```lua
local M = {}
local Job = require("plenary.job")
local api = vim.api -- Make sure this exists!
local fn = vim.fn

-- Inside get_api_key
local function get_api_key(name)
	local key = os.getenv(name)
	-- More detailed print: Show start of key or nil
	if key then
		print("[dingllm_debug] Getting API key for: ", name, "- Found: YES - Starts with: ", string.sub(key, 1, 4))
	else
		print("[dingllm_debug] Getting API key for: ", name, "- Found: NO (nil)")
		vim.notify("API key environment variable not found: " .. name, vim.log.levels.WARN)
	end
	return key
end

function M.get_lines_until_cursor()
	local current_buffer = vim.api.nvim_get_current_buf()
	local current_window = vim.api.nvim_get_current_win()
	local cursor_position = vim.api.nvim_win_get_cursor(current_window)
	local row = cursor_position[1]

	local lines = vim.api.nvim_buf_get_lines(current_buffer, 0, row, true)

	return table.concat(lines, "\n")
end

function M.get_visual_selection()
	local _, srow, scol = unpack(vim.fn.getpos("v"))
	local _, erow, ecol = unpack(vim.fn.getpos("."))

	if vim.fn.mode() == "V" then
		if srow > erow then
			return vim.api.nvim_buf_get_lines(0, erow - 1, srow, true)
		else
			return vim.api.nvim_buf_get_lines(0, srow - 1, erow, true)
		end
	end

	if vim.fn.mode() == "v" then
		if srow < erow or (srow == erow and scol <= ecol) then
			return vim.api.nvim_buf_get_text(0, srow - 1, scol - 1, erow - 1, ecol, {})
		else
			return vim.api.nvim_buf_get_text(0, erow - 1, ecol - 1, srow - 1, scol, {})
		end
	end

	if vim.fn.mode() == "\22" then
		local lines = {}
		if srow > erow then
			srow, erow = erow, srow
		end
		if scol > ecol then
			scol, ecol = ecol, scol
		end
		for i = srow, erow do
			table.insert(
				lines,
				vim.api.nvim_buf_get_text(0, i - 1, math.min(scol - 1, ecol), i - 1, math.max(scol - 1, ecol), {})[1]
			)
		end
		return lines
	end
end

function M.make_anthropic_spec_curl_args(opts, prompt, system_prompt)
	local url = opts.url
	local api_key = opts.api_key_name and get_api_key(opts.api_key_name)
	local data = {
		system = system_prompt,
		messages = { { role = "user", content = prompt } },
		model = opts.model,
		stream = true,
		max_tokens = 4096,
	}
	-- Add -sS for silent operation, show errors
	local args = { "-sS", "-N", "-X", "POST", "-H", "Content-Type: application/json", "-d", vim.json.encode(data) }
	if api_key then
		table.insert(args, "-H")
		table.insert(args, "x-api-key: " .. api_key)
		table.insert(args, "-H")
		table.insert(args, "anthropic-version: 2023-06-01")
	end
	table.insert(args, url)
	return args
end

function M.make_ollama_spec_curl_args(opts, prompt)
	local url = opts.url or "http://localhost:11434/api/generate"
	local data = {
		model = opts.model or "llama3.2",
		prompt = prompt,
	}
	-- Add -sS for silent operation, show errors
	local args = {
		"-sS",
		"-N",
		"-X",
		"POST",
		"-H",
		"Content-Type: application/json",
		"-d",
		vim.json.encode(data),
		url,
	}
	return args
end

function M.make_openai_spec_curl_args(opts, prompt, system_prompt)
	local url = opts.url
	local api_key = opts.api_key_name and get_api_key(opts.api_key_name)
	local data = {
		messages = { { role = "system", content = system_prompt }, { role = "user", content = prompt } },
		model = opts.model,
		temperature = 0.7,
		stream = true,
	}
	-- Add -sS for silent operation, show errors
	local args = { "-sS", "-N", "-X", "POST", "-H", "Content-Type: application/json", "-d", vim.json.encode(data) }
	if api_key then
		table.insert(args, "-H")
		table.insert(args, "Authorization: Bearer " .. api_key)
	end
	table.insert(args, url)
	return args
end

function M.write_string_at_cursor(str)
	-- Print *before* scheduling
	print("[dingllm_debug] write_string_at_cursor called with string length:", #str)
	vim.schedule(function()
		-- Print *inside* the scheduled function
		print("[dingllm_debug] write_string_at_cursor - SCHEDULED function executing.")
		local current_window = vim.api.nvim_get_current_win()
		local cursor_position = vim.api.nvim_win_get_cursor(current_window)
		local row, col = cursor_position[1], cursor_position[2]

		local lines = vim.split(str, "\n")
		print("[dingllm_debug] write_string_at_cursor - Split into", #lines, "lines.")

		vim.cmd("undojoin")
		print("[dingllm_debug] write_string_at_cursor - About to call nvim_put.")
		vim.api.nvim_put(lines, "c", true, true)
		print("[dingllm_debug] write_string_at_cursor - nvim_put call finished.")

		local num_lines = #lines
		local last_line_length = #lines[num_lines]
		vim.api.nvim_win_set_cursor(current_window, { row + num_lines - 1, col + last_line_length })
		print("[dingllm_debug] write_string_at_cursor - Cursor set.")
	end)
end

local function get_prompt(opts)
	local replace = opts.replace
	local visual_lines = M.get_visual_selection()
	local prompt = ""

	if visual_lines then
		prompt = table.concat(visual_lines, "\n")
		if replace then
			vim.api.nvim_command("normal! d")
			vim.api.nvim_command("normal! k")
		else
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", false, true, true), "nx", false)
		end
	else
		prompt = M.get_lines_until_cursor()
	end

	return prompt
end

function M.handle_anthropic_spec_data(data_stream, event_state)
	if event_state == "content_block_delta" then
		local json = vim.json.decode(data_stream)
		if json.delta and json.delta.text then
			M.write_string_at_cursor(json.delta.text)
		end
	end
end

function M.handle_openai_spec_data(data_stream)
	if data_stream:match('"delta":') then
		local json = vim.json.decode(data_stream)
		if json.choices and json.choices[1] and json.choices[1].delta then
			local content = json.choices[1].delta.content
			if content then
				M.write_string_at_cursor(content)
			end
		end
	end
end

function M.handle_ollama_spec_data(data_stream)
	local ok, json = pcall(vim.json.decode, data_stream)
	if ok and json and json.response then
		M.write_string_at_cursor(json.response)
	end
end

-- Inside make_gemini_spec_curl_args
-- Corrected function to handle Gemini API specifics
function M.make_gemini_spec_curl_args(opts, prompt, system_prompt)
	print("[dingllm_debug] Entering make_gemini_spec_curl_args")
	local api_key = opts.api_key_name and get_api_key(opts.api_key_name)
	if not api_key then
		vim.notify("Gemini API key not found for name: " .. (opts.api_key_name or "nil"), vim.log.levels.ERROR)
		return nil -- Cannot proceed without API key
	end

	-- Base URL for Gemini API V1 Beta
	local base_url = "https://generativelanguage.googleapis.com/v1beta/models/"
	local model = opts.model or "gemini-1.5-flash-latest" -- Default model
	local action = ":streamGenerateContent"
	-- API key as query parameter
	local key_param = "?key=" .. api_key
	-- *** ADD alt=sse for Server-Sent Events streaming format ***
	local sse_param = "&alt=sse"
	local full_url = base_url .. model .. action .. key_param .. sse_param

	print("[dingllm_debug] Gemini full_url with alt=sse:", full_url)

	-- Construct the payload according to Gemini API spec for streaming
	local contents = {}
	-- Note: Gemini's handling of system prompts can vary. Often it's part of the 'contents'
	-- or a separate 'system_instruction'. This example omits it for simplicity unless
	-- you specifically adapt the payload structure based on the model's documentation.
	if system_prompt and system_prompt ~= "" then
		print(
			"[dingllm_debug] System prompt provided for Gemini but might be ignored by current payload structure. Contents:",
			vim.inspect(contents)
		)
		-- Example structure if needed (uncomment/adapt):
		-- table.insert(contents, { role = "system", parts = { { text = system_prompt } } })
		-- OR use top-level system_instruction field if supported
	end

	-- *** Add print to check prompt before inserting ***
	print("[dingllm_debug] Prompt type before insert:", type(prompt))
	if type(prompt) == "string" then
		print("[dingllm_debug] Prompt value before insert (first 50 chars):", string.sub(prompt, 1, 50))
	else
		print("[dingllm_debug] Prompt value before insert is NOT a string:", prompt)
	end

	-- Add user prompt
	table.insert(contents, { role = "user", parts = { { text = prompt } } })

	local data = {
		contents = contents,
		generationConfig = {
			temperature = opts.temperature or 0.7,
			maxOutputTokens = opts.max_tokens or 2048, -- Adjust as needed
			-- topP, topK can also be added here
		},
		-- safetySettings = { ... } -- Optional: Add safety settings if needed
	}

	-- *** Add grounding tools if requested ***
	if opts.grounding == true then
		print("[dingllm_debug] Grounding with Google Search enabled.")
		data.tools = { { google_search = {} } }
	else
		print("[dingllm_debug] Grounding with Google Search disabled.")
	end

	-- Add -sS for silent operation, show errors
	local args = {
		"-sS",
		"-N",
		"-X",
		"POST",
		"-H",
		"Content-Type: application/json",
		"-d",
		vim.json.encode(data),
	}
	table.insert(args, full_url)

	print("[dingllm_debug] Gemini curl args:", vim.inspect(args))
	print("[dingllm_debug] Gemini data:", vim.inspect(data))
	return args
end

-- Inside handle_gemini_spec_data
-- Revert to simpler version expecting JSON chunks after "data: " prefix
function M.handle_gemini_spec_data(data_chunk, _)
	print("[dingllm_debug] handle_gemini_spec_data received chunk:", data_chunk)
	local ok, decoded_obj = pcall(vim.json.decode, data_chunk)

	if ok and decoded_obj then
		print("[dingllm_debug] Gemini decoded JSON object:", vim.inspect(decoded_obj))

		-- *** Check if candidates field exists before trying to access it ***
		if
			decoded_obj.candidates
			and type(decoded_obj.candidates) == "table"
			and decoded_obj.candidates[1]
			and decoded_obj.candidates[1].content
			and decoded_obj.candidates[1].content.parts
			and type(decoded_obj.candidates[1].content.parts) == "table"
			and decoded_obj.candidates[1].content.parts[1]
			and decoded_obj.candidates[1].content.parts[1].text
			and type(decoded_obj.candidates[1].content.parts[1].text) == "string"
		then
			-- Candidates field exists and has the expected structure
			local text_chunk = decoded_obj.candidates[1].content.parts[1].text
			print("[dingllm_debug] Gemini extracted text chunk:", text_chunk)
			M.write_string_at_cursor(text_chunk)
		else
			-- Candidates field might be missing (e.g., metadata object) or structure is wrong.
			-- Only print a warning if the structure looks partially valid but text is missing.
			if decoded_obj.candidates then
				print(
					"[dingllm_warn] Gemini response object structure invalid or text path not found. Object:",
					vim.inspect(decoded_obj)
				)
			else
				-- No candidates field, likely metadata - ignore silently.
				print("[dingllm_debug] Gemini decoded object ignored (no candidates field, likely metadata).")
			end
		end
	else
		print("[dingllm_debug] Gemini failed to decode JSON chunk. Chunk content:", data_chunk)
	end
end

--
-- *** MODIFIED: Function for Full File Context + Selection Focus ***
function M.prompt_with_file_and_selection_context(opts, make_curl_args_fn, handle_data_fn)
	print("[dingllm_debug] Entering prompt_with_file_and_selection_context")
	opts = opts or {}

	-- 1. Get Visual Selection (Mandatory for this function)
	local selection_lines = M.get_visual_selection() -- Use the original function
	if not selection_lines then
		print("[dingllm_debug] No visual selection found.")
		vim.notify("Visual selection required for this prompt type.", vim.log.levels.WARN)
		return
	end
	-- Ensure it's a string
	local selection_text = ""
	if type(selection_lines) == "table" then
		selection_text = table.concat(selection_lines, "\\n")
	else -- Should already be string for char mode, but handle just in case
		selection_text = selection_lines
	end
	if selection_text == "" then
		vim.notify("Visual selection is empty.", vim.log.levels.WARN)
		return
	end
	print("[dingllm_debug] Selection text length:", #selection_text)

	-- If replacing, escape visual mode now
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", false, true, true), "nx", false)

	-- 2. Get Full File Content
	local current_buffer = vim.api.nvim_get_current_buf()
	local all_lines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, true)
	local full_file_content = table.concat(all_lines, "\\n")
	print("[dingllm_debug] Full file content length:", #full_file_content)

	-- 3. Construct the Custom Prompt
	local custom_prompt = string.format(
		[[
You should replace the code or text in the snippet, that you are sent, only following the comments. Do not talk at all. Output valid code only.
Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them.
Other comments should left alone. Do not output backticks

The user has provided the full content of their current file for context.
Focus your response primarily on the specific snippet they have highlighted, using the full file context only as needed to understand the snippet.

--- FULL FILE CONTEXT ---
%s
--- END FULL FILE CONTEXT ---

--- FOCUS SNIPPET ---
%s
--- END FOCUS SNIPPET ---

Based on the snippet (and the full context if relevant), provide your response:]],
		full_file_content,
		selection_text
	)
	print("[dingllm_debug] Custom prompt length:", #custom_prompt)

	-- Handle opts.replace and cursor positioning
	if opts.replace then
		local start_pos_vim = vim.fn.getpos("'<")
		local start_row = start_pos_vim[2]
		local start_col = start_pos_vim[3] - 1
		vim.api.nvim_command('normal! gv"_d')
		vim.api.nvim_win_set_cursor(0, { start_row, start_col })
	end

	-- 4. Add the prepared prompt to opts and call the invoker directly
	opts.prepared_prompt = custom_prompt -- Add the prompt to opts
	print("[dingllm_debug] Added prepared_prompt to opts. Calling invoke_llm_and_stream_into_editor.")

	-- Call invoker directly, passing original functions and modified opts
	M.invoke_llm_and_stream_into_editor(
		opts,
		make_curl_args_fn, -- Pass original make_args function
		handle_data_fn -- Pass original handle_data function
	)
end

-- Make sure this new function is included in the returned table M
-- (It should be automatically if defined as M.function_name = function...)

function M.prompt_ollama(opts)
	opts = opts or {}
	local prompt = get_prompt(opts)
	local args = M.make_ollama_spec_curl_args({
		url = opts.url or "http://localhost:11434/api/generate",
		model = opts.model or "llama2",
	}, prompt)

	if active_job then
		active_job:shutdown()
		active_job = nil
	end

	active_job = Job:new({
		command = "curl",
		args = args,
		on_stdout = function(_, line)
			M.handle_ollama_spec_data(line)
		end,
		on_stderr = function(_, err)
			print("Error:", err)
		end,
		on_exit = function()
			active_job = nil
		end,
	})

	active_job:start()

	vim.api.nvim_clear_autocmds({ group = group })
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "DING_LLM_Escape",
		callback = function()
			if active_job then
				active_job:shutdown()
				print("LLM streaming cancelled")
				active_job = nil
			end
		end,
	})

	vim.api.nvim_set_keymap("n", "<Esc>", ":doautocmd User DING_LLM_Escape<CR>", { noremap = true, silent = true })
	return active_job
end

local group = vim.api.nvim_create_augroup("DING_LLM_AutoGroup", { clear = true })
local active_job = nil

function M.invoke_llm_and_stream_into_editor(opts, make_curl_args_fn, handle_data_fn)
	print("[dingllm_debug] Entering invoke_llm_and_stream_into_editor")
	vim.api.nvim_clear_autocmds({ group = group })

	local final_args -- Variable to hold the final arguments for curl
	local curr_event_state = nil

	local prompt_to_use
	local system_prompt_to_use

	-- Check if a prompt was prepared by the caller
	if opts.prepared_prompt then
		print("[dingllm_debug] Using prepared_prompt from opts.")
		prompt_to_use = opts.prepared_prompt
		-- System prompt is generally ignored/handled differently with prepared prompts
		system_prompt_to_use = nil -- Set system prompt to nil when using prepared prompt
		print("[dingllm_debug] Prepared prompt length:", #prompt_to_use)
	else
		-- Standard call path, get prompt normally
		print("[dingllm_debug] No prepared_prompt found. Using get_prompt().")
		prompt_to_use = get_prompt(opts)
		system_prompt_to_use = opts.system_prompt
			or "You are a tsundere uwu anime. Yell at me for not setting my configuration for my llm plugin correctly" -- Default system prompt
		print(
			"[dingllm_debug] Standard call prompt length:",
			prompt_to_use and #prompt_to_use or "nil",
			"System prompt exists:",
			system_prompt_to_use ~= nil
		)
	end

	-- Call the provider-specific make_args function
	final_args = make_curl_args_fn(opts, prompt_to_use, system_prompt_to_use)

	if not final_args then
		vim.notify("Failed to create LLM request arguments.", vim.log.levels.ERROR)
		print("[dingllm_debug] make_curl_args_fn returned nil")
		return -- Stop if args creation failed
	end
	print("[dingllm_debug] FINAL curl args to be used:", vim.inspect(final_args))

	local function parse_and_call(line)
		-- Add check for nil line before processing
		if line == nil then
			print("[dingllm_debug] parse_and_call received nil line, skipping.")
			return
		end
		print("[dingllm_debug] parse_and_call received raw line:", line)

		-- Revert to original SSE parsing logic
		local event = line:match("^event: (.+)$")
		if event then
			print("[dingllm_debug] parse_and_call matched event:", event)
			curr_event_state = event
			return -- Event lines don't usually have data for the handler
		end

		local data_match = line:match("^data: (.+)$")
		if data_match then
			print("[dingllm_debug] parse_and_call matched data prefix, passing chunk to handler:", data_match)
			handle_data_fn(data_match, curr_event_state) -- Pass only the JSON part
		else
			print("[dingllm_debug] parse_and_call - Line ignored (no event/data prefix):", line)
		end
	end

	if active_job then
		print("[dingllm_debug] Shutting down pre-existing active job before starting new one.") -- Debug print
		active_job:shutdown()
		active_job = nil
	end

	-- *** Add print right before creating the job ***
	print("[dingllm_debug] About to create Job. final_args type:", type(final_args))
	if type(final_args) == "table" then
		print("[dingllm_debug] final_args content just before Job:new:", vim.inspect(final_args))
	else
		print("[dingllm_debug] final_args is NOT a table just before Job:new. Value:", final_args)
	end

	active_job = Job:new({
		command = "curl",
		args = final_args, -- Use the captured final_args
		on_stdout = vim.schedule_wrap(function(_, out) -- Wrap in schedule_wrap for safety
			print("[dingllm_debug] Job on_stdout received:", out) -- Print right inside callback
			parse_and_call(out)
		end),
		on_stderr = vim.schedule_wrap(function(_, err) -- Wrap in schedule_wrap
			if err and err ~= "" then
				print("[dingllm_stderr] Curl stderr:", err) -- Make output distinct
				vim.notify("LLM Job stderr: " .. err, vim.log.levels.WARN) -- Also notify
			end
		end),
		on_exit = vim.schedule_wrap(function(_, code) -- Wrap in schedule_wrap
			print("[dingllm_debug] Job exited with code:", code)
			-- Check buffer on exit
			if gemini_stream_buffer ~= "" then
				print(
					"[dingllm_warn] Job exited, but Gemini buffer was not empty or fully processed:",
					gemini_stream_buffer
				)
			end
			active_job = nil
			gemini_stream_buffer = "" -- Ensure buffer is cleared on exit
			-- Clean up the escape mapping ONLY when the job finishes naturally or is cancelled
			pcall(api.nvim_del_keymap, "n", "<Esc>")
			-- pcall(api.nvim_del_keymap, 'i', '<Esc>') -- Consider if needed
		end),
		stderr_buffered = false, -- Process stderr line-by-line
	})

	print("[dingllm_debug] Starting curl job...") -- Add print
	active_job:start()

	-- Setup autocmd AFTER starting the job
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "DING_LLM_Escape",
		callback = function()
			M.cancel_llm_job() -- Call the new cancel function
		end,
	})

	-- Setup keymap AFTER starting the job and setting up autocmd
	vim.api.nvim_set_keymap("n", "<Esc>", ":doautocmd User DING_LLM_Escape<CR>", { noremap = true, silent = true })
	-- Consider if an insert mode escape is also needed:
	-- vim.api.nvim_set_keymap('i', '<Esc>', '<Cmd>doautocmd User DING_LLM_Escape<CR>', { noremap = true, silent = true })

	return active_job
end

-- New cancel function
function M.cancel_llm_job()
	print("[dingllm_debug] cancel_llm_job called.") -- Add print
	if active_job then
		print("[dingllm_debug] Shutting down active job.") -- Add print
		active_job:shutdown()
		print("LLM streaming cancelled.")
		active_job = nil
		gemini_stream_buffer = "" -- Clear Gemini stream buffer on cancel
		-- Clean up keymaps when cancelled
		pcall(api.nvim_del_keymap, "n", "<Esc>")
		-- pcall(api.nvim_del_keymap, 'i', '<Esc>') -- Match cleanup with setup
	else
		print("[dingllm_debug] No active job to cancel.") -- Add print
	end
end

return M
```

this is the plugin user config:

```lua
return {
  -- "bajistic/dingllm.nvim",
  -- Use a local directory for the plugin (e.g., for development)
  dir = "~/Projects/ZZ/dingllm.nvim", -- Specify the path to your local clone
  dev = true,
  -- name = "dingllm", -- Often redundant if 'dir' points to a directory named 'dingllm.nvim'
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local system_prompt =
      "You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks"
    local helpful_prompt = "You are a helpful assistant. What I have sent are my notes so far."
    local dingllm = require("dingllm")

    local function handle_open_router_spec_data(data_stream)
      local success, json = pcall(vim.json.decode, data_stream)
      if success then
        if json.choices and json.choices[1] and json.choices[1].text then
          local content = json.choices[1].text
          if content then
            dingllm.write_string_at_cursor(content)
          end
        end
      else
        print("non json " .. data_stream)
      end
    end

    local function custom_make_openai_spec_curl_args(opts, prompt)
      local url = opts.url
      local api_key = opts.api_key_name and os.getenv(opts.api_key_name)
      local data = {
        prompt = prompt,
        model = opts.model,
        temperature = 0.7,
        stream = true,
      }
      local args = { "-N", "-X", "POST", "-H", "Content-Type: application/json", "-d", vim.json.encode(data) }
      if api_key then
        table.insert(args, "-H")
        table.insert(args, "Authorization: Bearer " .. api_key)
      end
      table.insert(args, url)
      return args
    end

    -- Function to construct curl arguments for OpenAI API requests
    -- Creates the necessary headers, data payload and URL for API communication
    -- Includes authentication and request configuration
    local function llama_405b_base()
      dingllm.invoke_llm_and_stream_into_editor({
        url = "https://openrouter.ai/api/v1/chat/completions",
        model = "meta-llama/llama-3.1-405b",
        api_key_name = "OPEN_ROUTER_API_KEY",
        max_tokens = "128",
        replace = false,
      }, custom_make_openai_spec_curl_args, handle_open_router_spec_data)
    end

    local function groq_replace()
      dingllm.invoke_llm_and_stream_into_editor({
        url = "https://api.groq.com/openai/v1/chat/completions",
        model = "llama-3.1-70b-versatile",
        api_key_name = "GROQ_API_KEY",
        system_prompt = system_prompt,
        replace = true,
      }, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
    end

    local function groq_help()
      dingllm.invoke_llm_and_stream_into_editor({
        url = "https://api.groq.com/openai/v1/chat/completions",
        model = "llama-3.1-70b-versatile",
        api_key_name = "GROQ_API_KEY",
        system_prompt = helpful_prompt,
        replace = false,
      }, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
    end

    local function llama405b_replace()
      dingllm.invoke_llm_and_stream_into_editor({
        url = "https://api.lambdalabs.com/v1/chat/completions",
        model = "hermes-3-llama-3.1-405b-fp8",
        api_key_name = "LAMBDA_API_KEY",
        system_prompt = system_prompt,
        replace = true,
      }, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
    end

    local function llama405b_help()
      dingllm.invoke_llm_and_stream_into_editor({
        url = "https://api.lambdalabs.com/v1/chat/completions",
        model = "hermes-3-llama-3.1-405b-fp8",
        api_key_name = "LAMBDA_API_KEY",
        system_prompt = helpful_prompt,
        replace = false,
      }, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
    end

    local function anthropic_help()
      dingllm.invoke_llm_and_stream_into_editor({
        url = "https://api.anthropic.com/v1/messages",
        model = "claude-3-5-sonnet-20241022",
        api_key_name = "ANTHROPIC_API_KEY",
        system_prompt = helpful_prompt,
        replace = false,
      }, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
    end

    local function anthropic_replace()
      dingllm.invoke_llm_and_stream_into_editor({
        url = "https://api.anthropic.com/v1/messages",
        model = "claude-3-5-sonnet-20241022",
        api_key_name = "ANTHROPIC_API_KEY",
        system_prompt = system_prompt,
        replace = true,
      }, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
    end

    -- Corrected Gemini help function WITH GROUNDING
    local function gemini_help()
      dingllm.invoke_llm_and_stream_into_editor(
        -- Opts for the API call
        {
          api_key_name = "GEMINI_API_KEY", -- Ensure this env var is set!
          model = "gemini-2.5-pro-exp-03-25", -- Or your preferred Gemini model
          replace = false,
          temperature = 0.8,
          grounding = true, -- <<< ADD THIS LINE TO ENABLE GROUNDING
          max_tokens = 2048,
          -- Note: system_prompt is generally ignored by Gemini's standard API structure
          -- unless you modify make_gemini_spec_curl_args payload
          -- system_prompt = helpful_prompt,
        },
        -- Provider specific functions
        dingllm.make_gemini_spec_curl_args,
        dingllm.handle_gemini_spec_data
      )
    end

    -- Corrected Gemini replace function
    local function gemini_replace()
      dingllm.invoke_llm_and_stream_into_editor({
        api_key_name = "GEMINI_API_KEY",
        model = "gemini-2.5-pro-exp-03-25",
        replace = true,
        -- system_prompt = system_prompt, -- Same note about system_prompt
      }, dingllm.make_gemini_spec_curl_args, dingllm.handle_gemini_spec_data)
    end

    -- New function using the file+selection context with Gemini
    local function gemini_explain_selection()
      -- Use the new function from the plugin
      dingllm.prompt_with_file_and_selection_context(
        -- Opts for the API call
        {
          api_key_name = "GEMINI_API_KEY",
          model = "gemini-2.5-pro-exp-03-25",
          replace = true, -- Set to true if you want the LLM output to replace the selection
          temperature = 0.5,
        },
        -- Provider specific functions
        dingllm.make_gemini_spec_curl_args,
        dingllm.handle_gemini_spec_data
      )
    end

    -- concise comment description of following function
    --
    local function anthropic_explain_selection()
      dingllm.prompt_with_file_and_selection_context({
        url = "https://api.anthropic.com/v1/messages", -- Add this line
        api_key_name = "ANTHROPIC_API_KEY",
        model = "claude-3-5-sonnet-20240620",
        replace = true,
      }, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
    end

    -- Map the new functions
    vim.keymap.set("v", "<leader>iE", gemini_explain_selection, { desc = "Gemini File Context" })
    vim.keymap.set("v", "<leader>ie", anthropic_explain_selection, { desc = "Claude File Context" })

    -- Then, set your keymaps
    vim.keymap.set({ "n", "v" }, "<leader>ig", gemini_help, { desc = "Gemini" })
    vim.keymap.set({ "v" }, "<leader>iG", gemini_replace, { desc = "Gemini Replace" })

    vim.keymap.set({ "n", "v" }, "<leader>ii", anthropic_help, { desc = "Claude" })
    vim.keymap.set({ "v" }, "<leader>iI", anthropic_replace, { desc = "Claude Replace" })
    -- vim.keymap.set({ "n", "v" }, "<leader>ik", groq_replace, { desc = "llm groq" })
    -- vim.keymap.set({ "n", "v" }, "<leader>iK", groq_help, { desc = "llm groq_help" })
    -- vim.keymap.set({ "n", "v" }, "<leader>iL", llama405b_help, { desc = "llm llama405b_help" })
    -- vim.keymap.set({ "n", "v" }, "<leader>il", llama405b_replace, { desc = "llm llama405b_replace" })
    -- vim.keymap.set({ "n", "v" }, "<leader>io", llama_405b_base, { desc = "llama base" })
    -- TODO: ADD GOOGLE SEARCH WITH GROUNDING
    -- https://ai.google.dev/gemini-api/docs/grounding?lang=rest
  end,
}
```

# docs

explain how this plugin works in detail, describe each core functions and the interplay at a low level, showing snippets and adding the explanations as a comment. also how the used vim functions work, im trying to understand all of its doings

Here's a detailed explanation of the plugin's core functionality with code snippets and comments:

```lua
-- Core Function Flow:
-- 1. User triggers command via keymap
-- 2. Plugin gets selected text or context
-- 3. Constructs API request
-- 4. Streams response back into editor

-- Get visual selection from editor
function M.get_visual_selection()
    -- Gets positions of visual selection start/end
    local _, srow, scol = unpack(vim.fn.getpos("v"))
    local _, erow, ecol = unpack(vim.fn.getpos("."))
    
    -- Handles different visual modes:
    -- V: line-wise visual
    -- v: character-wise visual 
    -- CTRL-V: block-wise visual
    if vim.fn.mode() == "V" then
        -- For line-wise, get full lines between start/end
        if srow > erow then
            return vim.api.nvim_buf_get_lines(0, erow - 1, srow, true)
        else
            return vim.api.nvim_buf_get_lines(0, srow - 1, erow, true)
        end
    end
    -- ...rest of visual mode handling
end

-- Takes API response and writes it at cursor
function M.write_string_at_cursor(str)
    vim.schedule(function()
        -- Get current cursor position
        local current_window = vim.api.nvim_get_current_win()
        local cursor_position = vim.api.nvim_win_get_cursor(current_window)
        
        -- Split response into lines
        local lines = vim.split(str, "\n")
        
        -- Join multiple edits into single undo step
        vim.cmd("undojoin")
        
        -- Insert text at cursor
        vim.api.nvim_put(lines, "c", true, true)
        
        -- Update cursor position after insertion
        local num_lines = #lines
        local last_line_length = #lines[num_lines]
        vim.api.nvim_win_set_cursor(current_window, {
            row + num_lines - 1, 
            col + last_line_length
        })
    end)
end

-- Main driver function to initiate LLM request and handle streaming
function M.invoke_llm_and_stream_into_editor(opts, make_curl_args_fn, handle_data_fn)
    -- Prepare curl arguments based on LLM provider
    local final_args = make_curl_args_fn(opts, prompt_to_use, system_prompt_to_use)
    
    -- Create job to run curl command
    active_job = Job:new({
        command = "curl",
        args = final_args,
        -- Handle streaming response
        on_stdout = vim.schedule_wrap(function(_, out)
            parse_and_call(out)
        end),
        -- ...error handling and cleanup
    })
    
    -- Start the job
    active_job:start()
    
    -- Setup escape handling to cancel job
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "DING_LLM_Escape",
        callback = function()
            M.cancel_llm_job()
        end,
    })
end

-- Provider-specific handlers:

-- Anthropic/Claude API handler
function M.handle_anthropic_spec_data(data_stream, event_state)
    -- Parse streaming JSON response
    if event_state == "content_block_delta" then
        local json = vim.json.decode(data_stream)
        if json.delta and json.delta.text then
            -- Write each chunk as it arrives
            M.write_string_at_cursor(json.delta.text)
        end
    end
end

-- OpenAI API handler
function M.handle_openai_spec_data(data_stream)
    if data_stream:match('"delta":') then
        local json = vim.json.decode(data_stream)
        if json.choices and json.choices[1] and json.choices[1].delta then
            local content = json.choices[1].delta.content
            if content then
                M.write_string_at_cursor(content)
            end
        end
    end
end
```

Key Vim Functions Used:

```lua
-- vim.api.nvim_get_current_win()
-- Returns handle to current window

-- vim.api.nvim_win_get_cursor(winid)
-- Gets cursor position as {row, col}

-- vim.api.nvim_buf_get_lines(bufnr, start, end, strict)
-- Gets lines from buffer between start/end

-- vim.api.nvim_put(lines, type, after, follow)
-- Inserts lines at cursor
-- type: how to insert ("c" for characterwise)
-- after: insert after cursor
-- follow: move cursor

-- vim.fn.getpos(mark)
-- Gets position info for marks like "v" (visual start)

-- vim.schedule(callback)
-- Schedules callback to run on next event loop iteration
-- Used to avoid race conditions with editor state
```

The plugin flow works like this:

1. User activates a keymap that calls one of the provider functions (e.g. `anthropic_help()`)

2. This calls `invoke_llm_and_stream_into_editor()` with:
   - Provider-specific options
   - Function to build curl arguments
   - Function to handle responses

3. The plugin gets text context:
   - For normal mode: text up to cursor
   - For visual mode: selected text
   - For file context mode: full file + selection

4. Constructs API request using provider's curl args function

5. Starts curl job to stream request to API

6. As chunks arrive, the handler function:
   - Parses JSON response
   - Extracts text content
   - Calls write_string_at_cursor() to insert
   - Updates cursor position

7. Handles cancellation via Escape key

8. Cleans up job and mappings when complete

The plugin uses Neovim's Job API via plenary.nvim to handle the async streaming nature of LLM responses, and carefully manages editor state to provide a smooth experience.



# explain

explain this plugin

This plugin is a Neovim plugin that allows users to interact with various Large Language Models (LLMs) directly from within Neovim. Here's a breakdown of its main features:

1. Supported LLM Services:
- Anthropic's Claude
- Google's Gemini
- OpenAI's API
- Ollama (local LLM)
- Lambda Labs' LLaMA models
- Groq
- OpenRouter

2. Core Functionality:
- Allows sending text to LLMs from:
  - Visual selections
  - Current cursor position
  - Full file context with focused selections
- Supports streaming responses directly into the editor
- Can either append responses or replace selected text
- Handles API authentication and request formatting for each service

3. Key Features:
- Real-time streaming of LLM responses
- Cancellable operations (via Escape key)
- Support for system prompts
- Visual mode selection
- Error handling and debugging output
- Integration with Google Search grounding (for Gemini)

4. Main Operations:
- Help mode: Adds LLM response after cursor
- Replace mode: Replaces selected text with LLM response
- Context-aware mode: Sends both file context and selection

5. Configuration:
- Customizable keymaps for different operations
- Configurable system prompts
- API key management through environment variables
- Model selection per service

6. Example Keymaps (from config):
```lua
vim.keymap.set("v", "<leader>iE", gemini_explain_selection)   -- Gemini with file context
vim.keymap.set("v", "<leader>ie", anthropic_explain_selection) -- Claude with file context
vim.keymap.set({ "n", "v" }, "<leader>ig", gemini_help)      -- Gemini help mode
vim.keymap.set({ "v" }, "<leader>iG", gemini_replace)        -- Gemini replace mode
vim.keymap.set({ "n", "v" }, "<leader>ii", anthropic_help)   -- Claude help mode
vim.keymap.set({ "v" }, "<leader>iI", anthropic_replace)     -- Claude replace mode
```

7. Default System Prompts:
- Code replacement prompt: Focuses on following comments and replacing code
- Helper prompt: Acts as a helpful assistant for note-taking

This plugin is particularly useful for developers who want to:
- Get AI assistance while coding
- Refactor code using LLMs
- Get explanations of code sections
- Generate code based on comments
- Process and enhance documentation or notes

---

# FIX
add persistent notification using noice.nvim when the streaming is active until the response is completed and default lazyvim plugins only
insert the response in the current buffer where the cursor at the time was when the function was called
rn the response streams where the cursor currently is and when i change the buffer the response continues in the new buffer 

specify the line numbers to add the snippet to




---
I'll help modify the code to implement those features. Here's how we can modify the `write_string_at_cursor` function and add notification handling:

```lua
-- At the top of the plugin file, add:
local function notify_streaming_status(is_active)
  if not package.loaded["noice"] then return end
  
  if is_active then
    vim.notify("LLM Streaming Active", vim.log.levels.INFO, {
      title = "DingLLM",
      persistent = true,
      replace = true,
      render = "minimal",
      timeout = false,
      id = "dingllm_streaming"
    })
  else
    vim.notify("LLM Streaming Complete", vim.log.levels.INFO, {
      title = "DingLLM",
      id = "dingllm_streaming"
    })
  end
end

-- Store initial cursor position and buffer
local streaming_context = {
  buffer = nil,
  row = nil,
  col = nil
}

function M.write_string_at_cursor(str)
  vim.schedule(function()
    -- Initialize streaming context if not set
    if not streaming_context.buffer then
      streaming_context.buffer = vim.api.nvim_get_current_buf()
      local pos = vim.api.nvim_win_get_cursor(0)
      streaming_context.row = pos[1]
      streaming_context.col = pos[2]
      -- Start streaming notification
      notify_streaming_status(true)
    end

    -- Always insert at the stored position
    if vim.api.nvim_buf_is_valid(streaming_context.buffer) then
      local lines = vim.split(str, "\n")
      
      -- Get current content at target row
      local current_line = vim.api.nvim_buf_get_lines(
        streaming_context.buffer, 
        streaming_context.row - 1, 
        streaming_context.row, 
        false
      )[1] or ""

      -- Insert new content at stored position
      local new_line = current_line:sub(1, streaming_context.col) .. 
                      table.concat(lines, "\n") ..
                      current_line:sub(streaming_context.col + 1)
      
      vim.api.nvim_buf_set_lines(
        streaming_context.buffer,
        streaming_context.row - 1,
        streaming_context.row,
        false,
        {new_line}
      )

      -- Update col position for next chunk
      streaming_context.col = #new_line
    end
  end)
end

-- Modify the on_exit callback in invoke_llm_and_stream_into_editor:
on_exit = vim.schedule_wrap(function(_, code)
  print("[dingllm_debug] Job exited with code:", code)
  if gemini_stream_buffer ~= "" then
    print("[dingllm_warn] Job exited, but Gemini buffer was not empty:", gemini_stream_buffer)
  end
  active_job = nil
  gemini_stream_buffer = ""
  
  -- Clear streaming context and notify completion
  streaming_context.buffer = nil
  streaming_context.row = nil
  streaming_context.col = nil
  notify_streaming_status(false)
  
  pcall(api.nvim_del_keymap, "n", "<Esc>")
end),
```

This implementation:

1. Uses Noice.nvim for persistent notifications (included in LazyVim by default)
2. Stores the initial cursor position and buffer when streaming starts
3. Always inserts text at the stored position regardless of current cursor location
4. Shows a persistent notification while streaming is active
5. Cleans up the notification when streaming completes
6. Prevents the response from following the cursor to different buffers

To specify line numbers for insertion, you could add a parameter to the relevant functions:

```lua
-- Add to opts parameter in your config:
local function anthropic_help()
  dingllm.invoke_llm_and_stream_into_editor({
    url = "https://api.anthropic.com/v1/messages",
    model = "claude-3-5-sonnet-20241022",
    api_key_name = "ANTHROPIC_API_KEY",
    system_prompt = helpful_prompt,
    replace = false,
    insert_at_line = 10  -- Specify target line number
  }, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
end

-- Then modify the streaming_context initialization:
if not streaming_context.buffer then
  streaming_context.buffer = vim.api.nvim_get_current_buf()
  streaming_context.row = opts.insert_at_line or vim.api.nvim_win_get_cursor(0)[1]
  streaming_context.col = 0  -- Start at beginning of specified line
  notify_streaming_status(true)
end
```

