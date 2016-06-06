/* s-lonissl.f
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
        02.11.2004 saltanat - Т.з.ї1181 убрала проверку на поле Договор(lon.apr) "Подписан/Не подписан" 
        04/05/06 marinav Увеличить размерность поля суммы
        19.02.10   marinav - формат счета 20 

*/

def var s-glrem2 as char.

   disp
   "Форма платежа" s-ptype format "z9"
    help "1.Касса 3.Счет клиента 4.Перевод " space(10)
   "Валюта " s-crc format "zzz9" "Г/К" s-gl format "zzzzz9"
   "Счет  " s-acc format "x(20)" skip(1)
   "Остаток кредита" not-iss format ">,>>>,>>>,>>9.99" 
   "Платеж" c-code format "xxx" loniss format ">,>>>,>>>,>>9.99"
   /*validate(lon.apr = "OK", "Оформление кредита не закончено !")*/
   help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   c-code1 format "xxx"
   loniss1 format ">,>>>,>>>,>>9.99"
   /*validate(lon.apr = "OK", "Оформление кредита не закончено !")*/
   help "Введите сумму и ENTER; F1 - далее, F4 - выход" 
   skip(1)
   /*
   "Лизинг.аванс   " lon-avn format ">>>,>>>,>>9.99"
   "Платеж" c-code2 format "xxx" loniss2 format  ">>>,>>>,>>9.99"
   validate(lon.apr = "OK"," Оформление кредита не закончено !")
   help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   c-code21 format "xxx"  loniss21 format ">>>,>>>,>>9.99"
   validate(lon.apr = "OK", "Оформление кредита не закончено  !")
   help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   skip
   
   "Гарант.депозит " depo-atl format ">>>,>>>,>>9.99"
   "Платеж" depo-crc format "xxx" 
   depo-pay format  ">>>,>>>,>>9.99"
   validate(lon.apr = "OK"," Оформление кредита не закончено !")
   help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   depo-crc1 format "xxx"  
   depo-pay1 format ">>>,>>>,>>9.99"
   validate(lon.apr = "OK", "Оформление кредита не закончено !")
   help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   skip
  
   "Налог. %       " space(9) lon-pvn format "zz9.99" skip
   "Сумма налога   " pvn-sum format "zzz,zzz,zz9.99"
   "Платеж" v-pvncrc format "xxx"
   pvnpay format "zzz,zzz,zz9.99"
           help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   v-pvncrc1 format "xxx"
   pvnpay1   format "zzz,zzz,zz9.99" skip(1)
   
   "Комиссия1 %            " v-srv[1] format "zz9.99" 
   "Комиссия2 %       " v-srv[2] format "zz9.99" 
   "Комиссия3 % " v-srv[3] format "z9.99"   skip
   "        " c-code3 format "xxx" space(4) 
   s-srv[1] format ">>>,>>>,>>9.99" 
   "      " c-code4 format "xxx" s-srv[2] format ">>>,>>>,>>9.99"
   c-code5 format "xxx" s-srv[3] format ">>>,>>>,>>9.99" skip(1)
   
   "Получатель " v-name format "x(50)" skip
   "Примечание" s-glrem  format "x(320)" view-as fill-in size 60 by 1 skip(1)
   */
  "Получатель" at 7 v-name format "x(320)" view-as fill-in size 60 by 1  
  skip
  "Прим.2" at 7 s-glrem2 format "x(320)" view-as fill-in size 60 by 1 skip
 
   "Формировать транзакцию ?" ja

          with centered row 4 no-label width 90 frame s-loniss.
