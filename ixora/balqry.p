/* balqry.p
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


{global.i}

def new shared var aaa like aaa.aaa.
def new shared frame aaacif.
def new shared var l as char form "x(12)" extent 8.
def new shared var a like aaa.cbal extent 6.

def var bal like aaa.cbal label "ACT-BAL". /* cif.cr[1] - dr[1] */
def var cravail like aaa.cbal label "CR-AVAIL".
def var toavail like aaa.cbal label "TOT-AVAIL".
def var fv as char.
def var inc as int.

def buffer b-aaa for aaa.

repeat:

form "  ACCOUNT-#:" aaa.aaa crc.code to 74
     "      CIF-#:" cif.cif " - " cif.sname
     "     TAX-ID:" to 60 cif.pss format "  XXX-XXX-XXX" skip
     "    ADDRESS:" cif.addr[1] l[1] to 60 a[1] skip
     "            " cif.addr[2] l[2] to 60 a[2] skip
     "            " cif.addr[3] l[3] to 60 a[3] skip
     "      TEL-#:" cif.tel     l[4] to 60 a[4] skip
     l[7] aaa.rate              l[5] to 60 a[5] skip
     with frame aaacif row 1 centered no-label overlay title
     " A C C O U N T    Q U E R Y    W I T H    R U N N I N G    B A L A N C E "
     .

prompt aaa.aaa
       help "ENTER ACCOUNT OR HIT <F2> FOR HELP ... "
       with frame aaacif editing: {gethelp.i} end.

find aaa using aaa.aaa.

aaa = input aaa.aaa.

find cif where cif.cif = aaa.cif no-lock.
find crc where crc.crc = aaa.crc no-lock.
find lgr where lgr.lgr = aaa.lgr no-lock.
find led where led.led = lgr.led no-lock.

if aaa.loa <> "" then do:
  find b-aaa where b-aaa.aaa = aaa.loa no-lock.
  cravail = (b-aaa.dr[5] - b-aaa.cr[5])
          - (b-aaa.dr[1] - b-aaa.cr[1]).
end.

toavail = aaa.cbal + cravail - aaa.hbal.

display aaa.aaa cif.cif trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname cif.pss cif.addr[1] cif.addr[2] cif.addr[3]
        cif.tel with frame aaacif.

if led.drcr = -1 then do:
  display "ACCOUNT-BAL:" @ l[1] aaa.cr[1] - aaa.dr[1] @ a[1]
          "COLLECT-BAL:" @ l[2] aaa.cbal @ a[2]
          "   HOLD-BAL:" @ l[3] aaa.hbal @ a[3]
          "  AVAIL-BAL:" @ l[4] toavail @ a[4]
          "       INT%:" @ l[7] aaa.rate crc.code with frame aaacif.
  if aaa.loa <> "" then
    display "  CRE-AVAIL:" @ l[4] cravail @ a[4] with frame aaacif.
end.

else
  display "   PRIN-BAL:" @ l[1] aaa.dr[1] - aaa.cr[1] @ a[1]
          "    INT-BAL:" @ l[2] aaa.dr[2] - aaa.cr[2] @ a[2]
          "   SRVC-BAL:" @ l[3] aaa.dr[3] - aaa.cr[3] @ a[3]
          with frame aaacif.

run ballst.

end.
