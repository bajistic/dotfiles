if true then
  return {}
end

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
          grounding = false, -- <<< ADD THIS LINE TO ENABLE GROUNDING
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
