/* new-arp.p
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

/* new-arp.p
*/
def shared var s-acc like jl.acc.
def shared var s-gl  like gl.gl.
def shared var s-jh like jh.jh.
def shared var s-jl like jl.ln.
def var answer as log.
def shared var rtn as log initial yes.

{global.i}

find jh where jh.jh eq s-jh.
find jl where jl.jh eq jh.jh and jl.ln eq s-jl.
find gl where gl.gl eq s-gl.

main:
do transaction on error undo,return :

            create arp.
            arp.arp = jl.acc.
            arp.rdt = g-today.
            arp.who = g-ofc.
            arp.gl = gl.gl.
            arp.crc = jl.crc.
            arp.cif = jh.cif.

            update arp.type format "zzz" label "ТИП"
                   arp.geo format "x(3)" label "ГЕО"
                       validate(can-find(geo where geo.geo eq geo), "")  
                   arp.cgr label "ГРУППА"
                       validate(can-find(cgr where cgr.cgr eq cgr), "")
                       skip
                   arp.des label "ПРИМЕЧ."
                 /*  arp.dam[1]  label "AMOUNT"   when gl.type = "A"
                     arp.cam[1]  label "AMOUNT" when gl.type = "L"
                  */
                   arp.rem
                   arp.zalog  label "ЗАЛОГ ?"
                   arp.lonsec label "ОБЕСП."
                      validate(can-find(lonsec where lonsec.lonsec eq lonsec) 
                      or arp.lonsec eq 0, "")
                   arp.risk   label "РИСК"
                      validate(can-find(risk where risk.risk eq risk) 
                      or arp.risk eq 0, "")
                   arp.duedt  label "НАЧ.ДАТА" format "99/99/9999"
                   arp.penny  label "ДОХОДНОСТЬ К ПОГАШЕНИЮ :" validate(penny <= 100, "") 
       /*            arp.sts   */
                   with centered row 8 3 col frame arp.

end.

rtn = no.
