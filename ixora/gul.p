/* gul.p
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

define var skzt as decimal.
define var kkzt as integer.
define var susd as decimal.
define var kusd as integer.
define var sdm as decimal.
define var kdm as integer.
define var srr as decimal.
define var krr as integer.
define var suah as decimal.
define var kuah as integer.
define var seur as decimal.
define var keur as integer.
skzt=0.
kkzt=0.
susd=0.
kusd=0.
sdm=0.
kdm=0.
srr=0.
krr=0.
suah=0.
kuah=0.
seur=0.
keur=0.
displ "Юридические лица" with frame ccc1 no-label centered row 1.
find first crc where crc.crc=2.
/*message crc.rate[1] "Курс доллара" .*/
displ "Курс доллара" crc.rate[1] with frame kkk1 no-label row 2.

unix silent rm -f value("vipprag.img").
for each aaa where 
        aaa.sta <> 'C' and aaa.gl = 220310
       /*    no-lock no-error */
        break by aaa.crc by aaa.cr[1] - aaa.dr[1] :

       /* выберем юридические... */
        find first sub-cod where
         sub-cod.sub   = 'cln'    and
         sub-cod.acc   = string( aaa.cif )
         no-lock no-error.
         if not avail sub-cod then next.
     /*    displ aaa.crc aaa.cbal. */
    if aaa.cbal<>0 then do: 
         
         if aaa.crc=1 then do: 
            skzt=skzt + aaa.cbal.
            kkzt=kkzt + 1.
         end.
         if aaa.crc=2 then do:
            susd=susd + aaa.cbal.
            kusd=kusd + 1.
         end.
         if aaa.crc=3 then do:
            sdm=sdm + aaa.cbal.
            kdm=kdm + 1.
         end.
         if aaa.crc=4 then do:
            srr=srr + aaa.cbal.
            krr=krr + 1.
         end.
         if aaa.crc=5 then do:
            suah=suah + aaa.cbal.
            kuah=kuah + 1.
         end.
         if aaa.crc=11 then do:
            seur=seur + aaa.cbal.
            keur=keur + 1.
         end.
  end. 
end.
/*displ "Юридические лица" with frame ccc1 no-label centered row 1.*/

displ skzt label "KZT" format ">>>>>>>>>>9.99" kkzt label "" format "9999" susd label "USD" format ">>>>>>>>9.99" kusd label "" format "9999" sdm label "DM" format ">>>>>>>9.99" kdm label "" format "9999" srr label "RR" format ">>>>>>>9.99" krr label "" format "9999" with frame cc3 no-label centered row 10.

displ seur label "EUR" keur label "" format "9999" suah label "UAH" kuah format "9999" label "" with frame cc2 no-label centered row 14.
/* hide frame ccc1.*/
   hide frame kkk1.
output to value("vipprag.img").
  message "Курс доллара =" crc.rate[1] .
  displ "Юридические лица" with frame ccc2 no-label centered row 1.

  displ skzt label "KZT" format ">>>>>>>>>>9.99" kkzt format "9999" susd label "USD" format ">>>>>>>>9.99" kusd format "9999" sdm label "DM" format ">>>>>>>9.99" kdm format "9999" srr label "RR" format ">>>>>>>9.99" krr format "9999" with frame cc3 no-label centered row 5.

  displ seur label "EUR" keur format "9999" suah label "UAH" kuah format "9999"
with frame cc2 no-label centered row 10.
  
output close.             
  hide frame ccc1.
  hide frame ccc2.
  hide frame cc3.
  hide frame cc2.
run menu-prt1('vipprag.img').
              
