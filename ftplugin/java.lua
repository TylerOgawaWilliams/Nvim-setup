-- ~/.config/nvim/ftplugin/java.lua

-- This file runs when you open a Java file

local jdtls_ok, jdtls = pcall(require, "jdtls")
if not jdtls_ok then
  vim.notify("JDTLS not found, install with Mason", vim.log.levels.ERROR)
  return
end

-- Get project root - adjust this for your project structure
local root_markers = { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)
if not root_dir then
  vim.notify("No project root found", vim.log.levels.WARN)
  return
end

-- Setup workspace folders
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspace/") .. project_name

-- Find the JDTLS installation path through Mason
local mason_registry = require("mason-registry")
local jdtls_pkg = mason_registry.get_package("jdtls")
local jdtls_path = jdtls_pkg:get_install_path()

-- Find Java installation
local java_home = os.getenv("JAVA_HOME")
if not java_home then
  -- Fallback to a default or try to find it
  vim.notify("JAVA_HOME not set", vim.log.levels.WARN)
  java_home = "/usr/lib/jvm/default" -- Adjust this default path
end

-- Get platform-specific config
local path_separator = vim.fn.has("win32") == 1 and "\\" or "/"
local os_config
if vim.fn.has("mac") == 1 then
  os_config = "mac"
elseif vim.fn.has("unix") == 1 then
  os_config = "linux"
elseif vim.fn.has("win32") == 1 then
  os_config = "win"
end

-- Setup JDTLS config
local config = {
  cmd = {
    java_home .. "/bin/java", -- Java executable
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    
    -- JDTLS launcher jar
    "-jar", jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar",
    
    -- JDTLS config
    "-configuration", jdtls_path .. "/config_" .. os_config,
    
    -- Workspace
    "-data", workspace_dir,
  },
  
  -- LSP settings
  root_dir = root_dir,
  
  -- Language server settings
  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = "fernflower" },
      completion = {
        favoriteStaticMembers = {
          "org.junit.Assert.*",
          "org.junit.Assume.*",
          "org.junit.jupiter.api.Assertions.*",
          "org.junit.jupiter.api.Assumptions.*",
          "org.junit.jupiter.api.DynamicContainer.*",
          "org.junit.jupiter.api.DynamicTest.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse"
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*",
          "sun.*",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
        },
        hashCodeEquals = {
          useJava7Objects = true,
        },
        useBlocks = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          -- Add your Java runtimes
          {
            name = "JavaSE-17",
            path = java_home,
          },
        },
      },
    },
  },
  
  -- Command to create a project
  init_options = {
    bundles = {},
    extendedClientCapabilities = {
      progressReportProvider = true,
    },
  },
  
  -- JDTLS specific capabilities
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  
  -- Integration with other plugins
  on_attach = function(client, bufnr)
    -- Call the default LSP on_attach from LazyVim
    require("lazyvim.plugins.lsp.keymaps").on_attach(client, bufnr)
    
    -- JDTLS-specific commands
    jdtls.setup_dap({ hotcodereplace = "auto" })
    jdtls.setup.add_commands()
    
    -- Add Java-specific keymaps
    vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, { buffer = bufnr, desc = "Organize Imports" })
    vim.keymap.set("n", "<leader>jt", jdtls.test_class, { buffer = bufnr, desc = "Test Class" })
    vim.keymap.set("n", "<leader>jn", jdtls.test_nearest_method, { buffer = bufnr, desc = "Test Method" })
    vim.keymap.set("n", "<leader>jc", function() jdtls.extract_constant() end, { buffer = bufnr, desc = "Extract Constant" })
    vim.keymap.set("n", "<leader>jv", function() jdtls.extract_variable() end, { buffer = bufnr, desc = "Extract Variable" })
    vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method() end, { buffer = bufnr, desc = "Extract Method" })
    
    -- Enable inlay hints if available
    if vim.fn.has("nvim-0.10") == 1 then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
}

-- Start the language server
jdtls.start_or_attach(config)
