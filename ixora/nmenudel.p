/* nmenudel.p
 * MODULE
        Администратор
 * DESCRIPTION
        Удаление пункта главного меню со всем деревом
 * RUN
        
 * CALLER
        nmenumnt.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9-1-4-1
 * AUTHOR
        19.07.2004 nadezhda MX
 * CHANGES
        19.07.2004 sasco добавил удаление прав если надо
*/


define input parameter p-fname as char.
define input parameter p-delsec as logical.

do transaction on error undo, retry:
  run my_delmenu (p-fname).
end.

procedure my_delmenu.
  def input parameter p-menu as char.
  message p-delsec p-menu view-as alert-box.

  find nmenu where nmenu.fname = p-menu no-lock no-error.
  if not avail nmenu then return.

  if nmenu.proc = "" then do:
    for each nmenu where nmenu.father = p-menu exclusive-lock:
      if nmenu.proc = "" then run my_delmenu (nmenu.fname).
      else do:
        for each nmdes where nmdes.fname = nmenu.fname exclusive-lock:
          delete nmdes.
        end.
        delete nmenu.
        if p-delsec then do:
           for each sec where sec.fname = nmenu.fname:
               delete sec.
           end.
        end.
      end.
    end.
  end.

  for each nmdes where nmdes.fname = p-menu exclusive-lock:
    delete nmdes.
  end.

  find nmenu where nmenu.fname = p-menu exclusive-lock no-error.
  delete nmenu.

  if p-delsec then do:
     for each sec where sec.fname = nmenu.fname:
         delete sec.
     end.
  end.

end.

