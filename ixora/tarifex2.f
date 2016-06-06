/* tarifex2.f
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
        9-1-2-6-2 
 * AUTHOR
        29.06.2005 saltanat 
 * CHANGES
        27.01.10 marinav - расширение поля счета до 20 знаков
*/

def var v-am as char.

form
     tarifex2.aaa  format "x(20)" label "Счет" validate (can-find(aaa where aaa.aaa = tarifex2.aaa and aaa.cif = cif_ and aaa.sta ne 'c'),
                                  "Неверный счет клиента!")
     tarifex2.crc  format "99" column-label "Вал"
           validate (can-find(crc where crc.crc = tarifex2.crc),
                                  "Валюта не найдена ")
     tarifex2.ost  validate(tarifex2.ost >= 0," >=0 !") format "zzzz9.99"
      column-label "Сумма"
     tarifex2.proc format "z9.9999" column-label "  %  "
     tarifex2.min1 format "zzzzzz9" column-label " Мин "
     tarifex2.max1 format "zzzzzz9" column-label " Макс"
     tarifex2.nsost  validate(tarifex2.nsost >= 0," >=0 !") format "zzzzzzzzzzz9.99"
      column-label "Несн.ост"
     v-am format "x" column-label "AM"
     with overlay   column 1 row 7 11 down centered
     title string(code) + " " + tit + " по клиенту " + cif_ frame tarifex2 .
  message "F4 - выход ,RETURN - выбор ".


