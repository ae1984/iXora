/* h-vad-vards.f
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

define shared variable s-lon    like lon.lon.
form
     loncon.pase-nr     label "Паспорт номер.." help "F4-–r–; F1-t–l–k"
                        format "x(20)"
     loncon.rez-char[1] label "Персональн. код" help "F4-–r–; F1-t–l–k"
                        format "x(20)"
     loncon.pase-izd    label "Выдан ........." help "F4-–r–; F1-t–l–k"
     loncon.pase-pier   label "Прописан ......" help "F4-–r–; F1-t–l–k"
     loncon.rez-char[2] label "Место работы,тл" help "F4-–r–; F1-t–l–k"
                        format "x(60)"
     with side-labels title " Паспортные данные " + s-lon row 12
     overlay 1 columns frame pase.
