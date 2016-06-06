/* alktic.p
 * MODULE
        CALL CANTER
 * DESCRIPTION
        Парсер для файлов из Alcatel
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
        27.06.2005 marinav
 * CHANGES
*/


def stream t.
def stream st.
def var rcd as char.
def var f-name as char.
def var tmp1 as char.
def var tmp2 as char.
def var tmp3 as char.
def var i as deci.

def temp-table t_bal
    field number as char
    field userv as char format "x(50)"
    field dura  as char
    field wait  as char
    field calls as char
    field sta   as char
    field tim   as char
    field grp   as char.


f-name = 'tikets.txt'.

      unix silent value ("rcp `askhost`:c:\\\\tikets\\\\tikets.txt ./").

        INPUT FROM VALUE(f-name).
        create t_bal.
        repeat on error undo, leave:
          import unformatted tmp1 no-error.
          if trim(tmp1) = '' then create t_bal.
          tmp2 = substring(tmp1,1,4).
          tmp3 = substring(tmp1,41,4).
          case tmp2:
             when '(01)' then t_bal.number = substring(tmp1,21,10).
             when '(03)' then t_bal.userv = substring(tmp1,24,30).
             when '(09)' then t_bal.sta = substring(tmp1,30,15).
             when '(14)' then t_bal.dura = substring(tmp1,17,3).
             when '(35)' then t_bal.grp = substring(tmp1,29,6).
             when '(36)' then t_bal.wait = substring(tmp1,24,3).
             when '(37)' then t_bal.calls = substring(tmp1,30,3).
             when '(39)' then t_bal.tim = substring(tmp1,22,40).

          end case.
          case tmp3:
             when '(01)' then t_bal.number = substring(tmp1,61,10).
             when '(03)' then t_bal.userv = substring(tmp1,64,30).
             when '(09)' then t_bal.sta = substring(tmp1,70,15).
             when '(14)' then t_bal.dura = substring(tmp1,57,3).
             when '(35)' then t_bal.grp = substring(tmp1,69,6).
             when '(36)' then t_bal.wait = substring(tmp1,64,3).
             when '(37)' then t_bal.calls = substring(tmp1,70,3).
             when '(39)' then t_bal.tim = substring(tmp1,62,80).

          end case.
        end.
        input close.       


   output stream st to tiket.img.

   {html-title.i 
    &stream = " stream st "
    &title = " "
    &size-add = "x-"
   }

   put stream st unformatted   
     "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
       "<TR align=""center"" style=""font:bold"">" skip
         "<TD>N <br> п/п</TD>" skip
         "<TD>Дата/Время</TD>" skip
         "<TD>User name</TD>" skip
         "<TD>Duration</TD>" skip
         "<TD>Wating<br>duration</TD>" skip
         "<TD>Effective<br> call</TD>" skip
         "<TD>Номер<br> входящего <br>звонка</TD>" skip
         "<TD>Статус</TD>" skip
         "<TD>Номер <br>на который<br> поступил <br>звонок</TD>" skip
     "</TR>" skip.

for each t_bal where t_bal.sta begins 'in'.
    if t_bal.grp = 'C122' or t_bal.grp = 'C111' then do:
        i = i + 1.
        put stream st unformatted 
           "<TR>"
             "<TD>" i "</td>" skip
             "<TD>" tim format "x(20)" "</TD>" skip
             "<TD>" userv format "x(50)" "</TD>" skip
             "<TD>" dura "</TD>" skip
             "<TD>" wait "</TD>" skip
             "<TD>" calls "</TD>" skip
             "<TD>" number "</TD>" skip
             "<TD>"  if userv = 'No number' then 'Не отвечен' else 'Отвечен' "</TD>" skip
             "<TD>" grp "</TD>" skip
           "</TR>" skip.
    end.
end.
   put stream st unformatted "</TABLE>" skip.

   {html-end.i " stream st "}
 
   output stream st close.
   unix silent cptwin tiket.img excel.
