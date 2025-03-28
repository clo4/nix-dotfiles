set -gx EZA_COLORS "reset:fi=0:di=1;34:ln=36:or=31:ex=32:pi=90:so=90:bd=90:cd=90:oc=2:ur=2:uw=2:ux=2:ue=2:gr=2:gw=2:gx=2:tr=2:tw=2:tx=2:su=1;37:sf=1;37:xa=90:sn=2:sb=2;90:uu=2:un=2:uR=2;37:gu=2:gn=2:gR=2;37:xx=90:da=2:in=2:bl=2:hd=1;37:lp=36:mp=34"

# ----------------------------------------------------
# The rest of this file is to make it easy to generate
# ----------------------------------------------------
# 

# set -gx --path EZA_COLORS reset

# # Basic file types
# set -a EZA_COLORS "fi=0" # Regular files (normal)
# set -a EZA_COLORS "di=1;34" # Directories (bold blue)
# set -a EZA_COLORS "ln=36" # Symlinks (cyan)
# set -a EZA_COLORS "or=31" # Broken symlinks (red)
# set -a EZA_COLORS "ex=32" # Executable files (green)

# # Special files
# set -a EZA_COLORS "pi=90" # Named pipes (dark gray)
# set -a EZA_COLORS "so=90" # Sockets (dark gray)
# set -a EZA_COLORS "bd=90" # Block devices (dark gray)
# set -a EZA_COLORS "cd=90" # Character devices (dark gray)

# # Permissions (dimmed)
# set -a EZA_COLORS "oc=2" # Octal permissions
# set -a EZA_COLORS "ur=2" # User read
# set -a EZA_COLORS "uw=2" # User write
# set -a EZA_COLORS "ux=2" # User execute
# set -a EZA_COLORS "ue=2" # User execute (other file types)
# set -a EZA_COLORS "gr=2" # Group read
# set -a EZA_COLORS "gw=2" # Group write
# set -a EZA_COLORS "gx=2" # Group execute
# set -a EZA_COLORS "tr=2" # Others read
# set -a EZA_COLORS "tw=2" # Others write
# set -a EZA_COLORS "tx=2" # Others execute
# set -a EZA_COLORS "su=1;37" # Setuid/setgid (bold white)
# set -a EZA_COLORS "sf=1;37" # Setuid/setgid/sticky (other file types)
# set -a EZA_COLORS "xa=90" # Extended attributes (dark gray)

# # File size (dimmed)
# set -a EZA_COLORS "sn=2" # File size numbers
# set -a EZA_COLORS "sb=2;90" # File size units (dimmed dark gray)

# # User/Group (dimmed)
# set -a EZA_COLORS "uu=2" # Current user
# set -a EZA_COLORS "un=2" # Other users
# set -a EZA_COLORS "uR=2;37" # Root user (dimmed white)
# set -a EZA_COLORS "gu=2" # Your group
# set -a EZA_COLORS "gn=2" # Other groups
# set -a EZA_COLORS "gR=2;37" # Root group (dimmed white)

# # UI elements
# set -a EZA_COLORS "xx=90" # UI punctuation (dark gray)
# set -a EZA_COLORS "da=2" # Date (dimmed)
# set -a EZA_COLORS "in=2" # Inode (dimmed)
# set -a EZA_COLORS "bl=2" # Blocks (dimmed)
# set -a EZA_COLORS "hd=1;37" # Table header (bold white)
# set -a EZA_COLORS "lp=36" # Symlink path (cyan)

# # Mount points
# set -a EZA_COLORS "mp=34" # Mount points (blue)
