/* tswl.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*  13.11.02 KOVAL импорт for swift BLACK LIST OF ENTITIES */

def var pathname as char init 'C:\\MY\\SDN'.
update 
       pathname format "x(40)" label "Введите полный путь к файлам" 
       with side-labels centered frame pname.

hide frame pname.

pathname = caps(trim(pathname)).

def var i  as integer init 0.
def var s  as char init ''.
def var str as char init ''.
def var ds as char INIT ''.
def var ts as char INIT ''.
def var logic as logic init false.

def temp-table tf 
    field id       as integer
    field filename as char format "x(13)" 
    field ts       as char format "x(8)"
    field descr    as char format "x(25)".


pathname = replace ( pathname , '/', '\\' ).

if index(substr(pathname,length(pathname) ,1), '~\') <= 0 
   then pathname = pathname + '~\'.

do trans:
input through value("rsh `askhost` dir /b '" + pathname + "*.del '") no-echo.

    repeat:

      import unformatted s.

      if substr(caps(s),1,10) = 'THE SYSTEM' then do: 
         MESSAGE "Указан неверный путь к файлам: ~n" + pathname
         VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE " Внимание " .
         undo, return. 
      end.


      i = i + 1.
      s = caps(s).
      case substr(s,1,3):
       when 'SDN' then assign ds = 'Main table' ts = 'SDN'.
       when 'ADD' then assign ds = 'Address table' ts = 'ADD'.
       when 'ALT' then assign ds = 'Alternate identity table' ts = 'ALT'.
       otherwise  assign ds = 'UNKNOWN FILE!' ts = ''.
      end case.

      if ts<>'' then do:
       create tf.
       assign tf.id = i  
              tf.filename = s 
              tf.descr    = ds.
              tf.ts       = ts.
       assign ds = '' ts = '' .
      end.

   end.
    
input close.

end.

DEFINE QUERY q1 FOR tf.
def var fname as char init ''.

def browse b1 
    query q1 no-lock
    display 
        tf.filename  label " Файл "       format "x(8)"
        tf.descr     label " Описание "   format "x(25)"
        with 7 down .

def frame fr1
    b1
    with centered overlay view-as dialog-box title " Файлы доступные для импорта ".
    
on return of b1 in frame fr1 do:
        hide message. pause 0.
        assign
        fname = caps(trim(tf.filename)).
        ts = tf.ts.
        unix silent value("rm -f *.DEL").
        unix silent value("rm -f base.d").

        logic = false.
        MESSAGE "Вы действительно хотите импортировать файл ~n " + pathname + fname + " в Pragma ?~n"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Внимание" UPDATE logic.
        case logic:
            when false then return.
        end.        

        message "Минуточку. Идет загрузка файла " + fname + "...".
        unix silent value('rcp `askhost`:' + replace(pathname + fname,'\\','\\\\') + ' ./').
        unix silent value("sed -e 's/-0-/\?/g' -e 'y/@/ /' " + fname + " >base.d").

        case substr(fname,1,3):
        	when "SDN" then delete from swblsdn.
        	when "ALT" then delete from swblalt.
        	when "ADD" then delete from swbladd.
        end case.

        input from base.d.
        repeat: /* IMPORT */
        case substr(fname,1,3):
        	when "SDN" then do:
        		create swblsdn.
        		import swblsdn.
        	end.
        	when "ALT" then do:
        		create swblalt.
        		import swblalt.
        	end.
        	when "ADD" then do:
        		create swbladd.
        		import swbladd.
        	end.
        end case.

        end.    /* IMPORT */
        input close. pause 0.
        hide message. pause 0.
        b1:refresh(). pause 0.
end.  
                    
open query q1 for each tf.

if num-results("q1")=0 then do:
    MESSAGE "В каталоге " + pathname + " файлы не найдены."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE " Внимание " .
    return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL") .
ENABLE all with frame fr1 .
WAIT-FOR endkey of frame fr1 .
hide frame fr1 .

return. 

