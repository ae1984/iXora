/* savkm5.f
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


/* savkur.pp    01/11/94 - AGA
   курс валют для формы
*/


def var  nama as cha.

{v-kurs2.f}.

disp  stream pot
      g-comp format "x(40)" ku2 string(time,"HH:MM:SS")
      skip(0) with no-label
      no-underline width 130 .
disp  stream pot
      ku3  format "x(48)"
      string(g-today) skip(0) with width 130.
disp  stream pot
     "========================================================" +
     "==========" format "x(80)" skip(0).

  put stream pot ku4 at 20  skip(0).
  for each crc by crc.code:

    disp stream pot crc.code label "Nos."
		    crc.crc label "Kods"
		    crc.rate[9] label "Daudz." format "zzz,zz9"
		    crc.rate[2] label "Pёrk " format "zzz.99999"
		    crc.rate[3] label "P–rd." format "zzz.99999"
		    crc.rate[4] label "Pёrk " format "zzz.99999"
		    crc.rate[5] label "P–rd." format "zzz.99999"
		    crc.rate[1] label "LB vid." format "zzz.99999"
		    with down frame okon with width 80.



  end. /*   for each   */
put stream pot
	 "========================" + ku5 + "======================"
	 format "x(80)" skip(16).

