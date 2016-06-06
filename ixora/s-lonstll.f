/* s-lonstll.f
 * MODULE
        Кредитный модуль
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
       20.10.2003 marinav  добавлена оплата штрафов
       13/12/2005 madiar - добавил для информации сумму долга по комиссиям sds-com (без возможности оплаты)
        04/05/06 marinav Увеличить размерность поля суммы
*/

def var s-glrem2 as char.
def var s-glrem3 as char.
def var s-glrem4 as char.
form
  "Форма оплаты" at 7 s-ptype format "zz9"
    help "1.Касса 3.Клиентск.счет 4.Перевод 9.Списание"

  "Валюта   " s-crc format "z9"
        help "Введите код валюты и ENTER; F1 - далее, F4 - выход"

  "    G/G" s-gl
  k-p vacc  skip(1)
  
  "Осн.сумма " at 1 dam-cam1 format "z,zzz,zzz,zz9.99"
  "Платеж " v-code1 format "xxx"
   ppay1 format "z,zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   v-code format "xxx"
   ppay format "z,zzz,zzz,zz9.99" skip
   
   "Просроч. " at 2 v-amtod format "z,zzz,zzz,zz9.99"
   "Платеж " v-odcrc1 format "xxx"
   v-payod1 format "z,zzz,zzz,zz9.99" v-odcrc format "xxx"
   v-payod format "z,zzz,zzz,zz9.99"
   skip
   "Блокиров." at 2 v-amtbl format "z,zzz,zzz,zz9.99"
   "Платеж " v-blcrc1 format "xxx"
   v-paybl1 format "z,zzz,zzz,zz9.99" v-blcrc format "xxx"
   v-paybl format "z,zzz,zzz,zz9.99"
   
   skip /*(1)*/
   
   /*
  "Налог %   " space(9) lon-pvn format "zz9.99" skip

  "Нал.сумма " pvn-sum format "zzz,zzz,zz9.99"
  "Платеж " v-pvncrc1 format "xxx"
   pvnpay1 format "zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   v-pvncrc format "xxx"
   pvnpay format "zzz,zzz,zz9.99" skip
   */
  "Проценты  " at 1 vinttday format "->>,>>>,>>9.99"
  "Платеж " v-cd1 format "xxx"
   ipay1 format "z,zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   v-cd format "xxx"
   ipay format "z,zzz,zzz,zz9.99" skip

   "Просроч.%" at 2 v-intod format "z,zzz,zzz,zz9.99"
   "Платеж " v-iodcrc1 format "xxx"
   v-payiod1 format "z,zzz,zzz,zz9.99" v-iodcrc format "xxx"
   v-payiod format "z,zzz,zzz,zz9.99"
   skip

 /*  "Внебал. %" at 2 v-intoutbal format "z,zzz,zzz,zz9.99"*/
   "Платеж " v-iodcrc1 format "xxx"
   v-payiod1 format "z,zzz,zzz,zz9.99" v-iodcrc format "xxx"
   v-payiod format "z,zzz,zzz,zz9.99"
   
   skip
  

   "Штраф     " at 1 sds         format ">>>,>>>,>>9.99"
   "Платеж " sds-cd1 format "xxx"
   sds-pay1 format "z,zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   sds-cd  format "xxx"
   sds-pay format "z,zzz,zzz,zz9.99" skip

   "Ком.долг  " at 1 sds-com     format ">>>,>>>,>>9.99" skip
  /*
  "Штраф %   " at 7 sds     format "->>,>>>,>>9.99"
  "Платеж " sds-cd1 format "xxx"
   sds-pay1 format "zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   sds-cd  format "xxx"
   sds-pay format "zzz,zzz,zz9.99" skip
  
  "% по обяз." vsa     format "->>,>>>,>>9.99"
  "Платеж " vcd1 format "xxx"
   spay1 format "zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   vcd  format "xxx"
   spay format "zzz,zzz,zz9.99" skip
 
  "Оплата                   "
  "Платеж " algcd1 format "xxx"
   algpay1 format "zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   algcd  format "xxx"
   algpay format "zzz,zzz,zz9.99" skip
   */
   
  "Всего....." at 1 space(16)
  "Платеж " total-crc1 format "xxx"
   total-pay1 format "z,zzz,zzz,zz9.99"
       help "Введите сумму и ENTER; F1 - далее, F4 - выход"
   total-crc  format "xxx"
   total-pay format "z,zzz,zzz,zz9.99" skip
  /*
  "Перечисление  " loncon.konts format "x(10)"
  "Платеж " acd1 format "xxx"
   apay1 format "zzz,zzz,zz9.99"
   acd  format "xxx"
   apay format "zzz,zzz,zz9.99" skip
  */
  
  "Плательщик" at 1 v-name format "x(320)" view-as fill-in size 60 by 1
  skip
  "Прим.2" at 1 s-glrem2 format "x(320)" view-as fill-in size 60 by 1 skip
  "Прим.3" at 1 s-glrem3 format "x(320)" view-as fill-in size 60 by 1 skip
  
  "Формировать транзакцию ?" at 7 ja skip(0)

          with centered row 4 no-label frame lon.
  
  display s-ptype
          s-crc
          dam-cam1
          v-amtod
          v-amtbl
          v-payod1
          v-paybl1
          v-payod
          v-paybl
          v-code
          v-odcrc
          v-blcrc
          v-odcrc1
          v-blcrc1
          ppay1
          v-code1
          ppay
          /*
          lon-pvn
          pvn-sum
          pvnpay1
          pvnpay
          */
          vinttday
          v-intod
          v-cd
          ipay1
          v-cd1
          ipay
         /* v-intoutbal*/
          v-payiod1
          v-payiod
          
          sds
          sds-cd
          sds-pay1
          sds-cd1
          sds-pay
          /*
          vsa
          vcd
          spay1
          vcd1
          spay
          */
          total-pay
          total-pay1
          acd
          acd1
          s-glrem
          ja
          with frame lon.
