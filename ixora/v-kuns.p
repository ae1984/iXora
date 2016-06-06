/* v-kuns.p
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

/***************************************************************************\
*****************************************************************************
**  Program: v-kuns.p
**       By: AGA
** Descript: Two options: g-batch on/off
**
*****************************************************************************
\***************************************************************************/


/* v-kuns.p    13/11/93 - AGA
23/05/95 - AGA  - исправлена и дополнена
23/07/97 - AGA  - пеpеделана под ARHIV для HOME-BANKA
*/


DEF STREAM rpt.
DEF var  nama AS cha.
DEF var  crci LIKE crc.crc init 2.
DEF var  dpro AS date.
DEF var  dprr AS date.
DEF var  esti AS log init FALSE.
DEF var puti AS char.
DEF var jj AS int.

{v-kuns2.f}.
{mainhead.i KUNS }
IF NOT g-batch THEN
DO:
  {image1.i rpt.img}
END.
IF g-batch THEN
DO:
  crci = int(substring(g-cif,1,2)).
  dpro = date(int(substring(g-cif,6,2)),
  int(substring(g-cif,3,2)),
  int(substring(g-cif,9,4))).

  dprr = date(int(substring(g-cif,16,2)),
  int(substring(g-cif,13,2)),
  int(substring(g-cif,19,4))).
  nama = "kuns".
END.
ELSE
DO:
  dpro = date(month(g-today), 01, year(g-today)).
  dprr = g-today.
  UPDATE  crci /* validate(can-find( first crc where crc.crc = crci))*/
    LABEL "VAL®TA"
    dpro LABEL "DATUMS NO"
    dprr LABEL "L§DZ"
    WITH side-label row 6 OVERLAY CENTERED FRAME opt.
  nama = "rpt.img".
END.
FIND FIRST crc WHERE crc.crc EQ crci NO-LOCK.
OUTPUT STREAM rpt TO VALUE(nama) page-size 0.
DISP  STREAM rpt
  g-comp FORMAT "x(31)" ku2 string(TIME,"HH:MM:SS")
  ku6 string(g-today)
  SKIP(0) WITH NO-LABEL
  no-underline width 130 .
DISP  STREAM rpt
  ku3 + " - " + crc.code  FORMAT "x(40)"
  ku7 + string(dpro) + ku8 + string(dprr)
  FORMAT "x(50)" SKIP(0) WITH width 130.
DISP  STREAM rpt
  "========================================================" +
  "==========" FORMAT "x(80)" SKIP(0).

PUT STREAM rpt ku4  AT 20  SKIP(0).
FOR EACH crchis WHERE  crchis.rdt GE dpro
    AND crchis.rdt LE dprr
    AND crchis.crc EQ crci NO-LOCK :
  {v-kuns3.f}
  PAUSE 0.
  {v-kuns4.f}

  esti = TRUE.
END.
PUT STREAM rpt
  "========================" + ku5 + "======================"
  FORMAT "x(80)" SKIP(16).
OUTPUT STREAM rpt close.
IF esti THEN
DO: /* если встpетилась  хоть одна запись */
  IF NOT g-batch THEN
  UNIX silent value(dest)  value(nama).
  PAUSE 0.
END.
ELSE
UNIX silent /bin/rm -f  value(nama).
PAUSE 0.
RETURN.



