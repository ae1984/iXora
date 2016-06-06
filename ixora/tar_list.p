/* tar_list.p
 * MODULE
        Системные настройки
 * DESCRIPTION
        Список всех стандартынх тарифов банка
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9-1-2-6-2
 * AUTHOR
        17.11.2003 nadejda
 * CHANGES
        30.11.2004 saltanat - Внесла проверку на действующие тарифы.
        15.07.2005 saltanat - Включила поля пункта тарифа и полного наименования.
        09.09.2005 saltanat - Изменила формат поля пункт тарифа.
*/

{mainhead.i}

output to rep.txt.

find first cmp no-lock. 
put cmp.name skip(1)
 " Тарифы по кодам комиссий" skip(1) .

put " КОД  СЧЕТ Г/К   НАИМЕНОВАНИЕ КОМИССИИ                СУММА  ПРОЦЕНТ        МИНИМУМ       МАКСИМУМ  КОГДА УСТ  КТО УСТ  ПУНКТ                          ПОЛНОЕ НАИМ.ТАРИФА " skip 
 "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip .

for each tarif2 where tarif2.stat = 'r' no-lock break by num by nr by str5:
  if first-of(tarif2.nr) then do:
    find first tarif where tarif.num = tarif2.num and tarif.nr = tarif2.nr1 and tarif.stat = 'r' no-lock no-error.
    put skip(1) if avail tarif then tarif.pakalp else "Неизвестная группа тарифов" format "x(40)" skip 
        "-----------------------" skip.
  end.
  
  put " "  tarif2.str5 format "x(5)"
      " "  tarif2.kont format "999999"
      " "  tarif2.pakalp format "x(30)"
      " "  tarif2.ost format "zzz,zzz,zz9.99"
      " "  tarif2.proc format "zz9.9999"
      " "  tarif2.min1 format "zzz,zzz,zz9.99"
      " "  tarif2.max1 format "zzz,zzz,zz9.99"
      " "  tarif2.whn  format "99/99/9999"
      " "  tarif2.who  format "x(8)" 
      " "  tarif2.punkt format "x(30)" 
      " "  tarif2.name  skip.
end.

output close.

run menu-prt ("rep.txt").

