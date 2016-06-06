/* kdmarket.p Электронное кредитное досье

 * MODULE
        Кредитный модуль        
 * DESCRIPTION
        Анализ рынка
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню 
 * AUTHOR
        30/09/2005 madiar
 * BASES
        bank, comm
 * CHANGES
    05/09/06   marinav - добавление индексов
*/

{global.i}
{kd.i}
{pksysc.f}

if s-kdlon = '' then return.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def var s-full as char.
def var s-use as char.
def var s-land as char.

define frame fr skip(1)
       kdaffil.info[1] label "Описание" VIEW-AS EDITOR SIZE 65 by 10 skip
       s-full label "Общ.пл. " format "x(14)"
       s-use label "Пол.пл." format "x(14)"
       s-land label "Зем.уч." format "x(17)" skip
       kdaffil.info[5] label "Адрес   " VIEW-AS EDITOR SIZE 65 by 2 skip(1)
       kdaffil.whn      label "ПРОВЕДЕНО " kdaffil.who  no-label skip(1)
       with overlay width 78 side-labels column 2 row 3 
       title "ИНФОРМАЦИЯ ОБ ОБЕСПЕЧЕНИИ".

define new shared variable grp as integer init 5.
define var v-cod as char.
/*
on help of kdaffil.name in frame kdaffil22 do: 
  run h-kdname.  
  displ frame-value. pause.
  kdaffil.affilate = frame-value.
  kdaffil.name = frame-value.
  displ kdaffil.name with frame kdaffil22.
end.
*/
define variable s_rowid as rowid.
define var v-ln as inte init 1.


{jabrw.i 
&start     = " "
&head      = "kdaffil"
&headkey   = "code"
&index     = "cifnomc"
&formname  = "pksysc"
&framename = "kdaffil19"
&where     = " kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '19' "
&addcon    = "(kdlon.bank = s-ourbank)"
&deletecon = "(kdlon.bank = s-ourbank)"
&precreate = " "
&postadd   = "  s_rowid = rowid(kdaffil). find last kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '19' no-lock no-error.
   if avail kdaffil then v-ln = kdaffil.ln + 1. 
   find kdaffil where rowid(kdaffil) = s_rowid.
   kdaffil.ln = v-ln. kdaffil.bank = s-ourbank. kdaffil.code = '19'. kdaffil.kdcif = s-kdcif. 
   kdaffil.kdlon = s-kdlon.  kdaffil.who = g-ofc. kdaffil.whn = g-today. displ kdaffil.ln with frame kdaffil19.
   update kdaffil.lonsec kdaffil.name kdaffil.crc kdaffil.amount with frame kdaffil19. pause 0. 
   message 'F1 - Сохранить,   F4 - Выход без сохранения'.
   s-full = entry(1,kdaffil.info[4],'^').
   if num-entries(kdaffil.info[4],'^') > 1 then s-use = entry(2,kdaffil.info[4],'^').
   if num-entries(kdaffil.info[4],'^') > 2 then s-land = entry(3,kdaffil.info[4],'^').
   displ kdaffil.info[1] s-full s-use s-land kdaffil.info[5] kdaffil.whn kdaffil.who with frame fr.
   update kdaffil.info[1] s-full s-use s-land kdaffil.info[5] with frame fr.
   if trim(s-full) = '' then s-full = '0'. if trim(s-use) = '' then s-use = '0'. if trim(s-land) = '' then s-land = '0'.
   kdaffil.info[4] = s-full + '^' + s-use + '^' + s-land."
&prechoose = " if kdlon.bank = s-ourbank then message 'F4-Выход,   INS-Вставка.'. else message 'F4-Выход'."
&postdisplay = " "
&display   = " kdaffil.ln kdaffil.lonsec kdaffil.name kdaffil.crc kdaffil.amount " 
&highlight = " kdaffil.ln  kdaffil.lonsec "
&postkey   = "else 
   if keyfunction(lastkey) = 'RETURN'
      then do transaction on endkey undo, leave:
        if kdlon.bank = s-ourbank then do:
          update kdaffil.lonsec kdaffil.name kdaffil.crc kdaffil.amount with frame kdaffil19. pause 0.
          message 'F1 - Сохранить,   F4 - Выход без сохранения'.
        end.
        s-full = entry(1,kdaffil.info[4],'^').
        if num-entries(kdaffil.info[4],'^') > 1 then s-use = entry(2,kdaffil.info[4],'^').
        if num-entries(kdaffil.info[4],'^') > 2 then s-land = entry(3,kdaffil.info[4],'^').
        displ kdaffil.info[1] s-full s-use s-land kdaffil.info[5] kdaffil.whn kdaffil.who with frame fr.
        if kdlon.bank = s-ourbank then do:
          update kdaffil.info[1] s-full s-use s-land kdaffil.info[5] with frame fr.
          if trim(s-full) = '' then s-full = '0'. if trim(s-use) = '' then s-use = '0'. if trim(s-land) = '' then s-land = '0'.
          kdaffil.info[4] = s-full + '^' + s-use + '^' + s-land.
          kdaffil.who = g-ofc. kdaffil.whn = g-today.
        end.
        else do:
          pause.
        end.
        hide frame fr no-pause. 
      end. "
&end = "hide frame kdaffil19. hide frame fr."
}
hide message.



