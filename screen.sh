#!/bin/bash

# Array de comandos válidos
valid_commands=("join" "kill" "create" "help")

# Asigna los argumentos a variables
command="$1"
session_number="$2"
session_name="$3"

# Obtenemos la salida de screen -ls y la almacenamos en una variable
screen_list=$(screen -ls)

# Filtramos las líneas que contienen los nombres de las sesiones y las guardamos en un array
sessions=()
while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]*([0-9]+\.[^[:space:]]+) ]]; then
    sessions+=("${BASH_REMATCH[1]}")
  fi
done <<< "$screen_list"

print_main_help() {
  echo ""
  echo " + screen.sh - Valid options: ${valid_commands[@]}"
  echo " - Example of interactive options:"
  echo ""
  echo " 1. ./screen.sh help create"
  echo " 2. ./screen.sh help join"
  echo " 3. ./screen.sh help kill"
  echo ""
  echo " - Example of specific options:"
  echo " 4. ./screen.sh create <name>"
  echo " 5. ./screen.sh join <id>"
  echo " 6. ./screen.sh kill <id>"
  echo ""
}

# Función para eliminar una sesión
kill_session() {
  echo ""
  echo "Your sessions:"
  if [ ${#sessions[@]} -eq 0 ]; then
    echo "No active screen sessions found."
    exit 1
  fi
  for i in "${!sessions[@]}"; do
    echo " $i. ${sessions[i]}"
  done
  echo ""
  read -p "Please enter the number of the session you want to kill: " session_number
  if [[ $session_number =~ ^[0-9]+$ ]] && [ $session_number -ge 0 ] && [ $session_number -lt ${#sessions[@]} ]; then
    screen -X -S "${sessions[$session_number]}" quit
    echo "Session ${sessions[$session_number]} killed."
  else
    echo "Invalid session number."
    exit 1
  fi
}

# Función para crear una nueva sesión
create_session() {
  echo ""
  echo "screen.sh"
  echo " - Help: Creates a session with the assigned name. Example: screen -S my_session"
  echo " - Do not repeat the name of screens!! Yours sessions: "
  echo ""
  for i in "${!sessions[@]}"; do
    echo " $i. ${sessions[i]}"
  done
  echo ""
  read -p "Please enter the name of the session you want to create: " session_name
  if [[ -z "$session_name" ]]; then
    echo "Session name cannot be empty."
    exit 1
  elif [[ "$session_name" =~ \  ]]; then
    echo "Session name cannot contain spaces."
    exit 1
  else
    screen -S "$session_name"
    echo "Session $session_name created."
  fi
}

# Función para unirse a una sesión existente
join_session() {
  echo ""
  echo "screen.sh"
  echo " - Help: Attach to a screen session. Example: screen -x 12345.abcde"
  echo " - Choose the number of the session you want to join. Example: 0, 1, etc. Yours sessions: "
  echo ""
  if [ ${#sessions[@]} -eq 0 ]; then
    echo "No active screen sessions found."
    exit 1
  fi
  for i in "${!sessions[@]}"; do
    echo " $i. ${sessions[i]}"
  done
  echo ""
  read -p "Please enter the number of the session you want to join: " session_number
  if [[ $session_number =~ ^[0-9]+$ ]] && [ $session_number -ge 0 ] && [ $session_number -lt ${#sessions[@]} ]; then
    session_id=${sessions[$session_number]}
    echo "Attaching to session: $session_id"
    screen -x "$session_id"
  else
    echo "Invalid session number."
    exit 1
  fi
}

# Función principal que gestiona las sesiones
manage_sessions() {
  case "$1" in
    "kill")
      kill_session
      ;;
    "create")
      create_session
      ;;
    "join")
      join_session
      ;;
    *)
      print_main_help
      ;;
  esac
}

# Si el primer argumento es "help", muestra la ayuda y gestiona las sesiones
if [ "$command" = "help" ]; then
  manage_sessions "$session_number"
  exit 0
fi

# Verifica si el comando es válido
if [[ ! " ${valid_commands[@]} " =~ " $command " ]]; then
  print_main_help
  exit 1
fi

# Construye y ejecuta el comando según la opción seleccionada
case "$command" in
  "kill")
    if [[ -n "$session_number" ]]; then
      screen -X -S "$session_number" quit
      echo "Session $session_number killed."
    else
      echo "No session number provided."
    fi
    ;;
  "create")
    if [[ -n "$session_name" ]]; then
      screen -S "$session_name"
      echo "Session $session_name created."
    else
      echo "No session name provided."
    fi
    ;;
  "join")
    if [[ -n "$session_number" ]]; then
      screen -x "$session_number"
      echo "Attached to session $session_number."
    else
      echo "No session number provided."
    fi
    ;;
  *)
    echo "Command not implemented. Try our help:"
    print_main_help
    exit 1
    ;;
esac
