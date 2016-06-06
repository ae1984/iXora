/* trxbal-aaa.i
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
        04.12.2003 nadejda  - закомментарила все, что относится к профит-центрам
*/

                   vm-conv1 = v-accrued * crc.rate[1] / crc.rate[9] .
                   vm-conv = vm-conv + vm-conv1. 

                   if v-accrued > 0 then do:
                    find first crc where crc.crc  = aaa.crc no-lock . 
                    find first trxbal where trxbal.sub = "cif" and 
                        trxbal.acc = aaa.aaa and trxbal.lev = 2 and 
                        trxbal.crc = aaa.crc no-error.
                    if not avail trxbal then 
                     if not available trxbal then do:
                        create trxbal.
                        assign trxbal.sub = "cif"
                               trxbal.acc = aaa.aaa
                               trxbal.level = 2
                               trxbal.crc = aaa.crc.
                      end.
                     trxbal.cam = trxbal.cam + v-accrued.
                     aaa.cr[2] = aaa.cr[2] + v-accrued. 
                   end. 

                   if vm-conv1 > 0 then do:
                     find first trxbal where trxbal.sub = "cif" and 
                        trxbal.acc = aaa.aaa and trxbal.lev = 11 and 
                        trxbal.crc = 1 no-error.
                     if not available trxbal then do:
                        create trxbal.
                        assign trxbal.sub = "cif"
                               trxbal.acc = aaa.aaa
                               trxbal.level = 11
                               trxbal.crc = 1.
                      end.
                     trxbal.dam = trxbal.dam + vm-conv1.

  /* запись в таблицу начисленных процентов для Отчета по Профит-центрам */
  /* 04.12.2003 nadejda
                     find proftaccr where proftaccr.sub = "aaa" and proftaccr.acc = aaa.aaa exclusive-lock no-error.
                     if not avail proftaccr then do:
                       create proftaccr.
                       assign proftaccr.sub = "aaa"
                              proftaccr.acc = aaa.aaa.
                     end.
                     proftaccr.sum = proftaccr.sum + vm-conv1.
                     release proftaccr.
  */
  /* ------------------------------------------------------------------- */                 
                   end. 

