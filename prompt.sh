find_one_of_vcs_dir() {
  local scan_dir=$(pwd)

  # empty directory means no hg dir found
  hg_dir=''
  svn_dir=''
  git_dir=''
  arc_dir=''

  # searching the first parent with '.hg' dir inside
  while [[ $scan_dir != "/" ]]; do
    if [[ -d "${scan_dir}/.hg" ]]; then
      hg_dir="${scan_dir}"
      break
    elif [[ -d "${scan_dir}/.git" ]]; then
      git_dir="${scan_dir}"
      break
    elif [[ -d "${scan_dir}/.svn" ]]; then
      svn_dir="${scan_dir}"
      break
    elif [[ -d "${scan_dir}/.arc" ]]; then
      arc_dir="${scan_dir}"
      break
    fi
    scan_dir=$(dirname "$scan_dir")
  done
}

find_git_branch() {
  git_branch=''
  if [[ $git_dir != '' ]]; then
    # Based on: http://stackoverflow.com/a/13003854/170413
    if git_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null); then
      if [[ "$git_branch" == "HEAD" ]]; then
        git_branch='detached*'
      fi
    fi
  fi
}

find_git_dirty() {
  git_dirty=''
  if [[ $git_dir != '' ]]; then
    local status=$(git status --porcelain 2> /dev/null)
    if [[ "$status" != "" ]]; then
      git_dirty='*'
    fi
  fi
}

find_hg_branch() {
  hg_branch=''
  if [[ $hg_dir != '' ]]; then
    # there can be no 'branch' file if repo has been just created
    hg_branch=$(cat "${hg_dir}/.hg/branch" 2>/dev/null || hg branch 2>/dev/null)
  fi
}

find_arc_branch() {
  arc_branch=''
  if [[ $arc_dir != '' ]]; then
    # there can be no 'branch' file if repo has been just created
    arc_branch=$(cat .arc/HEAD  | grep 'Symbolic' | cut -d' ' -f 2 | tr -d '"' || arc branch 2>/dev/null)
  fi
}

find_svn_branch() {
  svn_branch=''
  if [[ $svn_dir != '' ]]; then
    svn_branch=$(svn info | grep 'Relative URL' | cut -c15- 2>/dev/null)
  fi
}

get_display_branch() {
  display_branch="${git_branch}${hg_branch}${svn_branch}${arc_branch}"
  if [[ $display_branch != '' ]]; then
    # add parentheses and space
    display_branch="(${display_branch}) "
  fi
}

get_all_info() {
  find_one_of_vcs_dir; find_git_branch; find_git_dirty; find_hg_branch; find_svn_branch; find_arc_branch; get_display_branch
}

PROMPT_COMMAND="get_all_info; $PROMPT_COMMAND"

# Default Git enabled prompt with dirty state
# export PS1="\u@\h \w \[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]\$ "

# Another variant:
# export PS1="\[$bldgrn\]\u@\h\[$txtrst\] \w \[$bldylw\]\$git_branch\[$txtcyn\]\$git_dirty\[$txtrst\]\$ "

# Default Git enabled root prompt (for use with "sudo -s")
# export SUDO_PS1="\[$bakred\]\u@\h\[$txtrst\] \w\$ "
