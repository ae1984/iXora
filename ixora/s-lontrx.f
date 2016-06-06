/* s-lontrx.f
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
        26.02.2004 marinav
 * CHANGES
        15/10/2004 madiyar - Добавились три новые комиссии
        06/05/2005 madiyar - Убрал просроченную индексацию
        07/03/2006 Natalya D. - добавила "Касса в пути".
        04/05/06 marinav Увеличить размерность поля суммы
        12/03/2007 madiyar - добавил ком.долг
        24/02/09   marinav - добавлено погашение через ARP
        19.02.10   marinav - формат счета 20
        10/08/10 aigul - погашение 4 и 5 уровней
        23/08/2010 madiyar - комиссия по кредитам бывших сотрудников
        17/09/2010 aigul - вывод суммы по валютам
        17.10.11 lyubov - изменила строки "Всего........." (СЗ от 14.10.11)
        25.07.2012 dmitriy - погашение комиссии по годовой ставке
        09/08/2012 kapar - ТЗ ASTANA-BONUS
*/

def var s-glrem2 as char.
def var s-glrem3 as char.
def var s-glrem4 as char.
def var s-glkom  as char.
form
  "Форма оплаты" at 7 s-ptype format "zz9"
    help "1.Касса 2.Касса в пути. 3.Клиентск.счет 4.Перевод 5.ARP 9.Списание"

  "Валюта   " s-crc format "z9"
        help "Введите код валюты и ENTER; F1 - далее, F4 - выход"

  "    G/G" s-gl k-p vacc  skip(1)

  "Основная сумма      " at 6 dam-cam1 format "z,zzz,zzz,zz9.99"
  "     Платеж " v-code1 format "xxx" " " ppay1 format "z,zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход" skip
  " "
         "Индексация ОД     " at 8 v-amt20 format "z,zzz,zzz,zz9.99"
         "     Платеж " v-odcrc20 format "xxx" " " v-pay20 format "z,zzz,zzz,zz9.99" skip
         "Просроченный ОД   " at 8 v-amtod format "z,zzz,zzz,zz9.99"
         "     Платеж " v-odcrc1 format "xxx" " " v-payod1 format "z,zzz,zzz,zz9.99" skip
     /*    "Инд.проср.ОД" at 8 v-amt21 format "zzz,zzz,zz9.99"
         "     Платеж " v-odcrc21 format "xxx" v-pay21 format "zzz,zzz,zz9.99" skip */


  "Проценты           " at 6 vinttday format "->,>>>,>>>,>>9.99"
  "     Платеж " v-cd1 format "xxx" " " ipay1 format "z,zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход"  skip

   " "
         "Индексация %%     " at 8 v-amt22 format "z,zzz,zzz,zz9.99"
         "     Платеж " v-odcrc22 format "xxx" " " v-pay22 format "z,zzz,zzz,zz9.99" skip
         "Просроченные %%   " at 8 v-intod format "z,zzz,zzz,zz9.99"
         "     Платеж " v-iodcrc1 format "xxx" " " v-payiod1 format "z,zzz,zzz,zz9.99" skip
     /*    "Инд.прос.%% " at 8 v-amt23 format "zzz,zzz,zz9.99"
         "     Платеж " v-odcrc23 format "xxx" v-pay23 format "zzz,zzz,zz9.99" skip */
  "% внесистемно 4ур   " at 6 v-4ur format "z,zzz,zzz,zz9.99"
         "     Платеж "  v-odcrc4 format "xxx" " " /*v-pay4ur format "z,zzz,zzz,zz9.99" */skip

  "Проценты ДАМУ      " at 6 damu_vinttday format "->,>>>,>>>,>>9.99"
  "     Платеж " damu_v-cd1 format "xxx" " " damu_ipay1 format "z,zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход"  skip

   " "
         "Просроч. %% ДАМУ  " at 8 damu_v-intod format "z,zzz,zzz,zz9.99"
         "     Платеж " damu_v-iodcrc1 format "xxx" " " damu_v-payiod1 format "z,zzz,zzz,zz9.99" skip
     /*    "Инд.прос.%% " at 8 v-amt23 format "zzz,zzz,zz9.99"
         "     Платеж " v-odcrc23 format "xxx" v-pay23 format "zzz,zzz,zz9.99" skip */
  "% внесистемно ДАМУ  " at 6 damu_v-4ur format "z,zzz,zzz,zz9.99"
         "     Платеж "  damu_v-odcrc4 format "xxx" " " /*v-pay4ur format "z,zzz,zzz,zz9.99" */skip

  "Проценты ASTANA    " at 6 astana_vinttday format "->,>>>,>>>,>>9.99"
  "     Платеж " astana_v-cd1 format "xxx" " " astana_ipay1 format "z,zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход"  skip

   " "
         "Просроч. %% ASTANA" at 8 astana_v-intod format "z,zzz,zzz,zz9.99"
         "     Платеж " astana_v-iodcrc1 format "xxx" " " astana_v-payiod1 format "z,zzz,zzz,zz9.99" skip
     /*    "Инд.прос.%% " at 8 v-amt23 format "zzz,zzz,zz9.99"
         "     Платеж " v-odcrc23 format "xxx" v-pay23 format "zzz,zzz,zz9.99" skip */
  "% внесистемно ASTANA" at 6 astana_v-4ur format "z,zzz,zzz,zz9.99"
         "     Платеж "  astana_v-odcrc4 format "xxx" " " /*v-pay4ur format "z,zzz,zzz,zz9.99" */skip


   "Штраф               " at 6 sds         format ">,>>>,>>>,>>9.99"
   "     Платеж " sds-cd1 format "xxx" " "
   sds-pay1 format "z,zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход" skip
   " "
   "Штрафы внесистем 5ур" at 6 sds5    format ">,>>>,>>>,>>9.99"
        "     Платеж " sds-cd5 format "xxx" " "
        /*sds-pay5 format "z,zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход" */skip

   "Комис - Кред.линия    " at 6 komcl     format ">>>,>>>,>>9.99"
   "     Платеж " komclcrc format "xxx" " "
   komcl-pay1 format "z,zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход" skip

   "Комис - Оформ.кр.док. " at 6 komprcr   format ">>>,>>>,>>9.99"
   "     Платеж " komprcrcrc format "xxx" " "
   komprcr-pay1 format "z,zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход" skip

   "Комис - Предост.кред. " at 6 komvacc   format ">>>,>>>,>>9.99"
   "     Платеж " komvacccrc format "xxx" " "
   komvacc-pay1 format "z,zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход" skip

   "Комис - Продление     " at 6 komprod   format ">>>,>>>,>>9.99"
   "     Платеж " komprodcrc format "xxx" " "
   komprod-pay1 format "z,zzz,zzz,zz9.99"
        help "Введите сумму и ENTER; F1 - далее, F4 - выход" skip

   "Ком.долг              " at 6 sds-com   format ">>>,>>>,>>9.99" skip
   "Комисс. по год.ставке " at 6 sds-koms  format ">>>,>>>,>>9.99"
   "     Платеж " total-crc-com format "xxx" " "
   ppay-kom format "z,zzz,zzz,zz9.99"

   "Всего штрафов........." at 6 total-pay-all format ">>>,>>>,>>9.99"
   "     Платеж " total-crc2 format "xxx" " "


   "Всего задолж.без штр-в" at 6 total-pay-all2 format ">>>,>>>,>>9.99"
   "     Платеж " total-crc1 format "xxx" " "

   total-pay1 format "z,zzz,zzz,zz9.99"
       help "Введите сумму и ENTER; F1 - далее, F4 - выход" skip

  "Плательщик" at 6 v-name format "x(320)" view-as fill-in size 70 by 1 skip
  "Прим.2" at 6 s-glrem2 format "x(320)" view-as fill-in size 70 by 1 skip
  "Прим.3" at 6 s-glrem3 format "x(320)" view-as fill-in size 70 by 1 skip
  "Прим.4" at 6 s-glkom  format "x(320)" view-as fill-in size 70 by 1 skip

  "Формировать транзакцию ?" at 6 ja skip(0)

          with centered row 3 no-label width 90 frame lon.

  display s-ptype
          s-crc
          dam-cam1
          v-amtod
          v-amt20
          /*v-amt21*/
          v-amt22
          v-4ur
          /*v-amt23*/
          v-amtbl
          v-payod1
          v-paybl1
          v-odcrc1
          v-odcrc20
          v-odcrc21
          v-odcrc22
          v-odcrc23
          v-odcrc4
          v-blcrc1
          ppay1
          v-code1
          vinttday
          v-intod
          v-pay20
          /*v-pay21*/
          v-pay22
          v-pay4ur
          /*v-pay23*/
          ipay1
          v-cd1
          v-payiod1

          damu_vinttday
          damu_v-cd1
          damu_ipay1
          damu_v-intod
          damu_v-payiod1
          damu_v-4ur
          damu_v-odcrc4

          astana_vinttday
          astana_v-cd1
          astana_ipay1
          astana_v-intod
          astana_v-payiod1
          astana_v-4ur
          astana_v-odcrc4

          sds
          sds5
          sds-pay1
          sds-pay5
          sds-cd1
          sds-cd5
          komcl
          komclcrc
          komcl-pay1
          komprcr
          komprcrcrc
          komprcr-pay1
          komvacc
          komvacccrc
          komvacc-pay1
          komprod
          komprodcrc
          komprod-pay1
          ppay-kom
          total-pay1
          total-pay-all
          total-pay-all2
          s-glrem
          ja
          with frame lon.

