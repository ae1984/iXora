/* dln.i
 * MODULE

 * DESCRIPTION

 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * BASES
        BANK COMM

 * AUTHOR
        02.07.2004 dpuchkov
 * CHANGES
*/


def {1} shared var s-sgnpath as char init "\/data\/9\/export\/docfl\/".
def {1} shared var s-tmppath as char init "tmpdln".
def {1} shared var s-hostmy as char.
def {1} shared var s-fileext as char init ".gif".

if "{1}" = "new" then do:
  find sysc where sysc.sysc =  "DLNPTH" no-lock no-error.
  if avail sysc then s-sgnpath = trim(sysc.chval).
  else do transaction on error undo, retry:
    create sysc.
    assign sysc.sysc =  "DLNPTH" 
           sysc.des = "Путь к файлу юридических дел"
           sysc.chval = s-sgnpath.
  end.
  if substr(s-sgnpath, length(s-sgnpath), 1) <> "/" then s-sgnpath = s-sgnpath + "/".

  find sysc where sysc.sysc = "DLNTMP" no-lock no-error.
  if avail sysc then s-tmppath = trim(sysc.chval).
  else do transaction on error undo, retry:
    create sysc.
    assign sysc.sysc = "DLNTMP"
           sysc.des = "Каталог времен.файлов юр. дел"
           sysc.chval = s-tmppath.
  end.
  if substr(s-tmppath, length(s-tmppath), 1) <> "/" then s-tmppath = s-tmppath + "/".

  input through askhost.
  repeat:
    import s-hostmy.
  end.
  input close.

end.

