/* yu-chs1.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

define input parameter vards as character.
define  shared variable rinda  as integer.
define  shared temp-table wrk
	       field    code     as character format "x(10)" label "Kods"
	       field    des      as character format "x(30)" label "Nosaukums"
	       field    ja-ne    as character format "x".
define  shared temp-table wrk2
	       field    des      as character format "x(30)".
define variable saraksts as character format "x(30)".
form saraksts no-label with down row rinda column 1 overlay no-box frame sar.

if rinda = 1
then clear frame sar all.
saraksts = vards.
create wrk2.
wrk2.des = saraksts.
display saraksts with frame sar.
down with frame sar.
rinda = rinda + 1.
for each wrk where wrk.ja-ne = "*":
    saraksts = " -" + wrk.des.
    create wrk2.
    wrk2.des = saraksts.
    display saraksts with frame sar.
    down with frame sar.
    rinda = rinda + 1.
end.
/*------------------------------------------------------------------------------
  #3.Programma attёlo uz monitora ekr–na izvёlёtos saraksta elementus,k– arЁ
     ieraksta tos darba fail– wrk2 t–l–kai izmantoЅanai
  #4.Ieejas inform–cija:
     - parametrs vards ar saraksta nosaukumu;
     - shared mainЁgais rinda  ar rindas numuru frame'a novietoЅanai uz ekr–na;
     - shared darba fails wrk satur
	      lauku    code     ar saraksta elementa kodu,
	      lauku    des      ar saraksta elementa nosaukumu,
	      lauku    ja-ne    ar atzЁmi par elementa izvёli.
  #5.Izejas inform–cija:
     - shared darba fails wrk2 satur
	      lauku    des      ar saraksta izvёlёt– elementa nosaukumu;
     - izvёlёto elementu nosaukumu attёlojums uz monitora ekr–na;
     - shared mainЁgais rinda satur pirm–s brЁv–s rindas numuru zem ЅЁ attёloju-
       ma.
------------------------------------------------------------------------------*/
