/* tarifex2add.f
 * MODULE
        Системные настройки
 * DESCRIPTION
        Настройка тарификатора
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        tar2_aex.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        9-1-2-6-3 
 * AUTHOR
        29.06.2005 saltanat 
 * CHANGES
*/

def var v-am as char.

form
     tarifex2.str5 label "Код"
     tarif2.punkt label "Пункт" 
     tarifex2.aaa label "Сч.кл."
     tarifex2.cif label "Клиент" 
     tarifex2.kont validate (can-find(gl where gl.gl = tarifex2.kont),
                 "Счет не найден ") column-label " Счет"
     tarifex2.pakalp  format "x(24)" column-label "Услуга"
     tarifex2.crc  format "99" column-label "Вал"
           validate (can-find(crc where crc.crc = tarifex2.crc),
                                  "Валюта не найдена ")
     tarifex2.ost  validate(tarifex2.ost >= 0," >=0 !") format "zzzz9.99"
      column-label "Сумма"
     tarifex2.proc format "z9.9999" column-label "  %  "
     tarifex2.min1 format "zzzzzz9" column-label " Мин "
     tarifex2.max1 format "zzzzzz9" column-label " Макс"
     tarifex2.nsost label 'Несн.ост.' validate(tarifex2.nsost >= 0," >=0 !") format "zzzz9.99"
     v-am format "x" column-label "AM"
     with overlay column 1 row 5 13 down frame tarifex2 .
  message "F4 - выход ,RETURN - выбор ".

