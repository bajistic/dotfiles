return {
  -- "bajistic/dingllm.nvim",
  -- Use a local directory for the plugin (e.g., for development)
  dir = "~/Projects/ZZ/llm.nvim", -- Specify the path to your local clone
  dev = true,
  -- name = "dingllm", -- Often redundant if 'dir' points to a directory named 'dingllm.nvim'
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local system_prompt =
      "You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks"
    local helpful_prompt = "You are a helpful assistant. What I have sent are my notes so far."
    local dingllm = require("llm")

    local function anthropic_help()
      dingllm.invoke_llm_and_stream_into_editor({
        url = "https://api.anthropic.com/v1/messages",
        model = "claude-3-7-sonnet-latest",
        api_key_name = "ANTHROPIC_API_KEY",
        system_prompt = helpful_prompt,
        replace = false,
      }, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
    end

    local function anthropic_replace()
      dingllm.invoke_llm_and_stream_into_editor({
        url = "https://api.anthropic.com/v1/messages",
        model = "claude-3-7-sonnet-latest",
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
          -- max_tokens = 2048,
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
    local function gemini_context_selection()
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
    local function anthropic_context_selection()
      dingllm.prompt_with_file_and_selection_context({
        url = "https://api.anthropic.com/v1/messages", -- Add this line
        api_key_name = "ANTHROPIC_API_KEY",
        model = "claude-3-7-sonnet-latest",
        replace = true,
      }, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
    end

    -- Map the new functions
    vim.keymap.set("v", "<leader>iE", gemini_context_selection, { desc = "Gemini File Context" })
    vim.keymap.set("v", "<leader>ie", anthropic_context_selection, { desc = "Claude File Context" })

    -- Then, set your keymaps
    vim.keymap.set({ "n", "v" }, "<leader>ig", gemini_help, { desc = "Gemini" })
    vim.keymap.set({ "v" }, "<leader>iG", gemini_replace, { desc = "Gemini Replace" })

    vim.keymap.set({ "n", "v" }, "<leader>ii", anthropic_help, { desc = "Claude" })
    vim.keymap.set({ "v" }, "<leader>iI", anthropic_replace, { desc = "Claude Replace" })
    -- TODO: ADD GOOGLE SEARCH WITH GROUNDING
    -- https://ai.google.dev/gemini-api/docs/grounding?lang=rest
  end,
}
