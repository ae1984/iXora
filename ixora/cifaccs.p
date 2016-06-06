/* cifaccs.p
 * MODULE
        Клиенты и их счета
 * DESCRIPTION
        Список счетов клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        s-cifchk.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.11
 * AUTHOR
        04.11.03 sasco
 * CHANGES
        27.01.10 marinav - расширение поля счета до 20 знаков
*/

{functions-def.i}

define shared variable s-cif like cif.cif.
define shared variable g-ofc as character.
define stream rep.
 
  def var v-ofcname as char init "(не найден в списке офицеров)".
  def var v-rezid as char init "(не указан)".
  def var v-secek as char init "(не указан)".
  def var v-ecdivis as char init "(не указан)".

  find first aaa where aaa.cif = s-cif no-lock no-error.
  if not available aaa then do:
    message " Нет счетов у данного клиента".
    pause.
    return.
  end.
  
  find ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then v-ofcname = ofc.name.

  find cif where cif.cif = s-cif no-lock no-error.
  find sub-cod where sub-cod.acc = s-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnsts" no-lock no-error.
  if available sub-cod then do:
    v-rezid = sub-cod.ccode.
    find codfr where codfr.codfr = "clnsts" and codfr.code = sub-cod.ccode no-lock no-error.
    v-rezid = "(" + v-rezid + ") " + codfr.name[1].
  end.

  find sub-cod where sub-cod.acc = s-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
  if available sub-cod then do:
    v-secek = sub-cod.ccode.
    find codfr where codfr.codfr = "secek" and codfr.code = sub-cod.ccode no-lock no-error.
    v-secek = "(" + v-secek + ") " + codfr.name[1].
  end.

  find sub-cod where sub-cod.acc = s-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "ecdivis" no-lock no-error.
  if available sub-cod then do:
    v-ecdivis = sub-cod.ccode.
    find codfr where codfr.codfr = "ecdivis" and codfr.code = sub-cod.ccode no-lock no-error.
    v-ecdivis = "(" + v-ecdivis + ") " + codfr.name[1].
  end.

  output stream rep to rptaaa.img.
  put stream rep
  FirstLine( 1, 1 ) format "x(70)" skip
  "Исполнитель :  " v-ofcname format "x(50)" skip(2)
  "СЧЕТА КЛИЕНТА" skip(1)
  "Код клиента       :  " cif.cif format "x(6)" skip
  "Наименование      :  " cif.name format "x(40)" skip
  "Резидентство      :  " v-rezid format "x(30)" skip
  "Сектор экономики  :  " v-secek format "x(30)" skip
  "Отрасль экономики :  " v-ecdivis format "x(40)" skip(1)
  fill("-", 90) format "x(90)" skip
  "   N счета             | Название        |  Группа  | Счет Г/К |         Остаток  | Статус" skip
  fill("-", 90) format "x(90)" skip.

  for each aaa where aaa.cif = s-cif no-lock by aaa.aaa.
    find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
    put stream rep  " "
       aaa.aaa  " | "
       lgr.des  " | "
       lgr.led "  " lgr.lgr  " |  "
       lgr.gl   "  | "
       aaa.cr[1] - aaa.dr[1] format ">,>>>,>>>,>>9.99-" "| "
       aaa.sta format "x(1)" skip.
  end.
  put stream rep 
    fill("-", 90) format "x(90)" skip.

  output stream rep close.
  run menu-prt("rptaaa.img").
  unix silent rm rptaaa.img.
