shift

wp() {
  local SERVICE=$(get_arg -s false $@)

  case $SERVICE in

  nginx)
    configure_nginx $@
    configure_hosts_file $@
    exit 0
    ;;
  apache)
    configure_apache $@
    configure_hosts_file $@
    exit 0
    ;;
  *)
    configure_nginx $@
    configure_apache $@
    configure_hosts_file $@
    ;;

  esac
}

configure_nginx() {
  sudo cp $DIR_PATH/files/nginx-wp.conf /etc/nginx/sites-available/$1.conf
  sudo sed -i "s/<domain>/$1/g" /etc/nginx/sites-available/$1.conf
  REPO=$(sed_escape_char $2 '/')
  sudo sed -i "s/<repo>/$REPO/g" /etc/nginx/sites-available/$1.conf
  sudo ln -s /etc/nginx/sites-available/$1.conf /etc/nginx/sites-enabled/
  if [ ! -d "$LOG_DIR$1" ]; then
    sudo mkdir $LOG_DIR$1
  fi
  sudo service nginx restart
}

configure_apache() {
  sudo cp $DIR_PATH/files/apache-wp.conf /etc/apache2/sites-available/$1.conf
  sudo sed -i "s/<domain>/$1/g" /etc/apache2/sites-available/$1.conf
  REPO=$(sed_escape_char $2 '/')
  sudo sed -i "s/<repo>/$REPO/g" /etc/apache2/sites-available/$1.conf
  sudo a2ensite $1.conf
  if [ ! -d "$LOG_DIR$1" ]; then
    sudo mkdir $LOG_DIR$1
  fi
  sudo service apache2 reload
}

configure_hosts_file() {
  sudo echo -e "\n" >>/mnt/c/Windows/System32/drivers/etc/hosts
  sudo echo "127.0.0.1 $1 www.$1" >>/mnt/c/Windows/System32/drivers/etc/hosts
  sudo echo "::1 $1 www.$1" >>/mnt/c/Windows/System32/drivers/etc/hosts
}

case $1 in

help)
  echo -e "Type 'run host [arg] help' for more information.\n"
  echo -e "          ${GREEN}host${NC} | Configure hosting."
  echo -e "          ${YELLOW}Args${NC} | ${BLUE}[type]${NC} The type of site being hosted."
  echo -e "               | -> wp ${BLUE}[domain-name] [repo-path]${NC}"
  ;;
wp)
  case $2 in

  help)
    echo -e "          ${GREEN}host${NC} | Configure hosting."
    echo -e "            ${GREEN}wp${NC} | Create a WordPress hosting."
    echo -e "          ${YELLOW}Args${NC} | ${BLUE}[domain-name]${NC} The domain name used for the hosting. Example: domain.loc"
    echo -e "               | ${BLUE}[repo-path]${NC} The site repository absolute path."
    echo -e "       ${YELLOW}Options${NC} | ${BLUE}-s${NC} Specify nginx or apache. Leave this option to apply both."
    exit 0
    ;;
  *)
    shift
    validate_args 2 $@
    wp $@
    ;;

  esac
  ;;
*)
  print_error "Wrong command."
  ;;

esac
