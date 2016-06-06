/* r-lnrsk30.p
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
        10/09/2004 madiar - почему-то было "bal_cif.nom begins 'd'" - опечатка?. Поменял на 'z'
        15/09/2004 madiar - не опечатка. Поменял обратно
*/

/**/

{global.i}
def input parameter v-cif like bal_cif.cif.
def input parameter v-dat like bal_cif.rdt.

define var w-lon like bal_cif.amount extent 17.
def var i as integer.

find cif where cif.cif = v-cif no-lock no-error.

define shared stream s1.

put stream s1 '             Финансовый отчет ' cif.name skip(1).
put stream s1 '                                                          тыс.тенге' skip.
put stream s1 '---------------------------------------------------------------------------' skip.
put stream s1 '               Актив                                  ' v-dat skip.   
put stream s1 '' skip.
put stream s1 '---------------------------------------------------------------------------' skip.
put stream s1 '' skip.

      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dat 
          and bal_cif.nom begins 'd' use-index nom:
          w-lon[i] = bal_cif.amount.
          i = i + 1.
      end.

                                                              
put stream s1 "   Доход от реализации продукции             " w-lon[1] ' ' w-lon[1] / w-lon[1] * 100 format '->>9.9' '%'  skip.
put stream s1 "   Себестоимость реализованной продукции     " w-lon[2] ' ' w-lon[2] / w-lon[1] * 100 format '->>9.9' '%'  skip.
put stream s1 "   Валовый доход                             " w-lon[3] ' ' w-lon[3] / w-lon[1] * 100 format '->>9.9' '%'  skip.
put stream s1 "   Расходы периода - всего:                  " w-lon[4] ' ' w-lon[4] / w-lon[1] * 100 format '->>9.9' '%'  skip. 
put stream s1 "   в том числе - общие и администр. расходы  " w-lon[5] ' ' w-lon[5] / w-lon[1] * 100 format '->>9.9' '%'  skip.        
put stream s1 "               - расходы по реализации       " w-lon[6] ' ' w-lon[6] / w-lon[1] * 100 format '->>9.9' '%'  skip.
put stream s1 "               - расходы по процентам        " w-lon[7] ' ' w-lon[7] / w-lon[1] * 100 format '->>9.9' '%'  skip.        
put stream s1 "   Доход (-убыток) от основной деятельности  " w-lon[8] ' ' w-lon[8] / w-lon[1] * 100 format '->>9.9' '%'  skip.
put stream s1 "   Доход (-убыток) от неосновной деятельности" w-lon[9] ' ' w-lon[9] / w-lon[1] * 100 format '->>9.9' '%'  skip.
put stream s1 "   Доход (-убыток) до налогообложения        " w-lon[10] ' ' w-lon[10] / w-lon[1] * 100 format '->>9.9' '%'  skip.
put stream s1 "   Расходы по подоходному налогу             " w-lon[17] ' ' w-lon[17] / w-lon[1] * 100 format '->>9.9' '%'  skip.
put stream s1 "   Доход (-убыток) после налогообложения     " w-lon[11] ' ' w-lon[11] / w-lon[1] * 100 format '->>9.9' '%'  skip. 
put stream s1 "   Убыток (доход) от чрезвычайных ситуаций   " w-lon[12] ' ' w-lon[12] / w-lon[1] * 100 format '->>9.9' '%'  skip.
put stream s1 "   ЧИСТЫЙ ДОХОД (-УБЫТОК) (NI)               " w-lon[13] ' ' w-lon[13] / w-lon[1] * 100 format '->>9.9' '%'  skip.
put stream s1 "   Среднедневная выручка                     " w-lon[14] ' ' w-lon[14] / w-lon[1] * 100 format '->>9.9' '%'  skip.
put stream s1 "   Среднедневные расходы                     " w-lon[15] ' ' w-lon[15] / w-lon[1] * 100 format '->>9.9' '%'  skip.
put stream s1 "   Чистая прибыль (-убыток) (среднедневная)  " w-lon[16] ' ' w-lon[16] / w-lon[1] * 100 format '->>9.9' '%'  skip(10).

