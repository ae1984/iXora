/* cif-bal.p
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

/* cif-bal.p  */

define shared var s-cif like cif.cif.
def var vcrcr as char format "x(15)".
def var xx as int.
{cif-bal.v}

find cif where cif.cif eq s-cif.

for each crc where crc.sts ne 9:

 tdda = 0.
 tsav = 0.
 tcda = 0.
 tcsa = 0.
 toda = 0.
 taaa = 0.
 ttda = 0.

 do xx = 1 to 3:
 ttrl[xx] = 0 .
 toll[xx] = 0 .
 tpll[xx] = 0 .
 tacl[xx] = 0 .
 tlon[xx] = 0 .
 end.

 tlcr[1] = 0 . tlcr[2] = 0.
 do xx = 1 to 4:
 tigm[xx] = 0 .
 tbil[xx] = 0 .
 tdbd[xx] = 0 .
 tlen[xx] = 0 .
 tgua[xx] = 0 .
 ttot[xx] = 0 .
 end.
 tclt = 0.

 cdda = 0.
 csav = 0.
 ccda = 0.
 ccsa = 0.
 coda = 0.
 caaa = 0.
 ctda = 0.
 ctrl = 0.
 coll = 0.
 cpll = 0.
 cacl = 0.
 clon = 0.
 clcr = 0.
 cbil = 0.
 cdbd = 0.
 clen = 0.
 cgua = 0.
 ctot = 0.
 cclt = 0.
 cucc = 0.

{cif-bal.i}
vcrcr = crc.des.
display  vcrcr   skip
        "===============" skip
        "                       ОСТАТОК             ЗА ГОД       "
        " ВЫПЛ.ПРОЦЕНТ"
        skip(1)
        "ДЕПОЗИТ  :  " taaa skip(1)
        "ОВЕРДРАФТ:  " toda skip(1)
        "КРЕДИТ:     " ttrl[1] ttrl[2] ttrl[3] skip
        "O/L КРЕДИТ: " toll[1] toll[2] toll[3] skip
        "P/L КРЕДИТ: " tpll[1] tpll[2] tpll[3] skip
        "A/C:        " tacl[1] tacl[2] tacl[3] skip(1)
        "АККРЕДИТИВ: " tlcr[1] skip(1)
        "СЧЕТ К ОПЛ.:" tbil[1] tbil[2] tbil[3] skip
        "           "  tbil[4] "" skip
        with centered row 2 no-label overlay top-only frame bal.
color display message vcrcr  with frame bal.
pause 10.
end.
