/* kasein.p
 * MODULE
     CALL-Center
 * DESCRIPTION
     Ввод курсов валют на Казахстанской Фондовой вирже
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        call.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
       16
        
 * AUTHOR
      torbaev
        
 * CHANGES
     ДатаИзменения   ЛогинАвтораИзменения   ОписаниеИзменения
     21-07-2004      torbaev                Ввод курсов биржи
     27-07-2004      torbaev                исправил мелкие ошибки
     11.08.2004      saltanat               почти полностью изменила
*/

{yes-no.i}
{mainhead.i}

def var v-title as char.
def var v-time as integer.

def temp-table t-kasecrc 
    field crc as inte
    field des as char
    field who as char
    field tim as char
    field regdt as date init ?
    field code as char
    field decpnt as inte
    field rate as deci extent 9 format "zzz,zz9.99"
        index icrc crc.

v-title = "Ввод курсов KASE".


find last kasecrchis where crc = 2 no-lock no-error.
if avail kasecrchis then do:
  create t-kasecrc.
         t-kasecrc.crc = kasecrchis.crc.
         t-kasecrc.des = kasecrchis.des.
         t-kasecrc.decpnt  = kasecrchis.decpnt.
         t-kasecrc.code  = kasecrchis.code.
         t-kasecrc.regdt = g-today.
	 t-kasecrc.who = g-ofc. 
	 t-kasecrc.tim = string(time,"hh:mm:ss").
  v-time = time.
end.


{jabrw-call.i 
&start     = "displ v-title format 'x(50)' at 25 with row 4 no-box no-label frame f-header."
&head      = "t-kasecrc"
&headkey   = "crc"
&index     = "icrc"
&formname  = "kasef"
&framename = "f-kaseedit"
&where     = " true "

&addcon    = " false "
&deletecon = " true "
&postcreate = " "
&prechoose = "displ skip 'Enter - редактировать, <P>- просм. последний курс, <F1>- сохранить, <F4>- выход' format 'x(80)'
              with row 12 no-box ."

&postdisplay = " "
&display   = " t-kasecrc.crc t-kasecrc.des t-kasecrc.rate[1] format 'zzz9.99'  t-kasecrc.rate[2] format 'zzz9.99'
                t-kasecrc.rate[3] format 'zzz9.99' t-kasecrc.rate[4] format 'zzz9.99'
               t-kasecrc.code t-kasecrc.regdt t-kasecrc.tim with no-labels "
&highlight = " t-kasecrc.crc  "

&update   = " t-kasecrc.rate[1] t-kasecrc.rate[2] t-kasecrc.rate[3] t-kasecrc.rate[4] "
&postupdate = " "

&postkey   = "if keyfunction(lastkey) = 'GO' then run fr-exit. 
              if keyfunction(lastkey) = 'P' then run fr-pro."

&end = "hide frame f-kaseedit. hide frame f-header. hide frame f-footer.  "
}
hide message.


procedure fr-exit.

if yes-no ('', 'Вы действительно хотите сохранить KASE курс на сегодня ?') then do:
/* записать измененные данные */
for each t-kasecrc :


  find kasecrc where kasecrc.crc = t-kasecrc.crc no-lock no-error.
  if not avail  kasecrc then do:
    message " Not exists  kasecrc with crc =" string(t-kasecrc.crc) view-as alert-box.
    next.
  end.
 

        do transaction:
             /*-------------------------------------------------------*/
               find current kasecrc exclusive-lock.
                 update 
                   
                        kasecrc.crc = t-kasecrc.crc
                        kasecrc.des = t-kasecrc.des
                        kasecrc.rate[1] = t-kasecrc.rate[1]
                        kasecrc.rate[2] = t-kasecrc.rate[2]
                        kasecrc.rate[3] = t-kasecrc.rate[3]
                        kasecrc.rate[4] = t-kasecrc.rate[4]
                        kasecrc.decpnt  = t-kasecrc.decpnt 
                        kasecrc.code  = t-kasecrc.code
                        kasecrc.who = g-ofc
                        kasecrc.regdt = g-today.
                        kasecrc.tim = v-time.
              /*-------------------------------------------------------*/
                 create kasecrchis.
                 assign 
                        kasecrchis.crc     = t-kasecrc.crc
                        kasecrchis.des     = t-kasecrc.des 
                        kasecrchis.rate[1] = t-kasecrc.rate[1] 
                        kasecrchis.rate[2] = t-kasecrc.rate[2] 
                        kasecrchis.rate[3] = t-kasecrc.rate[3] 
                        kasecrchis.rate[4] = t-kasecrc.rate[4] 
                        kasecrchis.decpnt  = t-kasecrc.decpnt
                        kasecrchis.code    = t-kasecrc.code
                        kasecrchis.who     = t-kasecrc.who 
                        kasecrchis.tim     = v-time
                        kasecrchis.regdt   = kasecrc.regdt
                        kasecrchis.rdt     = today. /* System date */
               release kasecrc.
              /*-------------------------------------------------------*/
        end.
end.
end.
end procedure.

/* Процедура для просмотра последних данных */
procedure fr-pro.
   find last kasecrchis where kasecrchis.crc = 2 no-lock no-error.
   if avail kasecrchis then do:
      displ kasecrchis.crc      format 'Z9' column-label "Номер" 
            kasecrchis.des      format "X(23)"  column-label "Назв. валюты"
            kasecrchis.rate[1]  format "zzz9.99" column-label "Средневзв. "
            kasecrchis.rate[2]  format "zzz9.99" column-label "Минимум "
            kasecrchis.rate[3]  format "zzz9.99" column-label "Максимум "
            kasecrchis.rate[4]  format "zzz9.99" column-label "Закрытие "
            kasecrchis.code     format "x(3)" column-label "Мнемо"
            kasecrchis.who      column-label "Кто рег."
            kasecrchis.regdt    format "99/99/9999" column-label "Рег.дата"
            string(kasecrchis.tim, "hh:mm:ss") label "Рег.Время"
       with centered title "Последний курс". 
   end. 
end procedure.

