read_globals = { "vim" }

max_comment_line_length = false
codes = true

exclude_files = {}

ignore = {
  "122", -- setting read-only field env.? of global vim
  "113", -- accessing undefined variable
  "143", -- accessing undefined field are.same of global assert
  "311", -- unused variable
  "631", -- line is too long
}

read_globals = { "vim" }
