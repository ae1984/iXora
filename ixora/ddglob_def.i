/* ddglob_def.i
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

     /*    ddglob_def.i     */
/* Рекомендуется при добавлении новых констант корректировать файл nosglob.p */
/*****************************************************************************/

/***********************************************************************/
/*                  Блок 1 для поля stat в файле ddlig                 */
/***********************************************************************/
/* Значения поля sost в файле ddlig */
&GLOBAL-DEFINE DL_DEL   '00'   /* удаленный                      */
&GLOBAL-DEFINE DL_ACT   '01'   /* действующий                      */
&GLOBAL-DEFINE DL_SUSP  '02'   /* приостановленный        */

/* Текстовые константы для поля stat в файле comm */
&GLOBAL-DEFINE DLT_DEL   "Slegts vai anulёts"    /* */
&GLOBAL-DEFINE DLT_ACT   "DarbojoЅais"  
&GLOBAL-DEFINE DLT_SUSP  "Apturёts"  

/***********************************************************************/
/*                Блок 2 для поля t_oper в файле ddlig , ddopr                 */
/***********************************************************************/
/* Значения поля t_oper в файле ddlig */
&GLOBAL-DEFINE DL_NEAB    '0'   /* Не абонентский платеж                */
&GLOBAL-DEFINE DL_AB      '1'   /* Абонентский платеж                     */

/* Текстовые константы для поля t_oper в файле ddlig */
&GLOBAL-DEFINE DLT_NEAB    "Ne kom.maks."   /* Зачисление на счет                     */
&GLOBAL-DEFINE DLT_AB      "Komunal.maks."   /* Обычный платеж */

/***********************************************************************/
/*               Блок 3 для поля stat в файле ddopr                  */
/***********************************************************************/
&GLOBAL-DEFINE DO_AN   '00'   /* счет анулирован   */
&GLOBAL-DEFINE DO_R    '01'   /* счет выставлен    */
&GLOBAL-DEFINE DO_NOT  '02'   /* oper–cija nav izpildЁta  */
&GLOBAL-DEFINE DO_OP   '05'   /* выполнена операция */
&GLOBAL-DEFINE DO_DEL  '06'   /* операция анулир */

/* Текстовые константы для поля stat в файле ddopr */
&GLOBAL-DEFINE DOT_AN   'Anulёts'  
&GLOBAL-DEFINE DOT_R     'Rё±ins apmaksai'  
&GLOBAL-DEFINE DOT_NOT   'Neizpild.'  
&GLOBAL-DEFINE DOT_OP    'IzpildЁts'  
&GLOBAL-DEFINE DOT_DEL   'Dzёsts'  

/***********************************************************************/
/*               Блок 4 для поля sterr в файле ddopr                  */
/***********************************************************************/
/* Значения поля steerr в файле ddopr */
&GLOBAL-DEFINE DO_OK   '00'   /* OK  */
&GLOBAL-DEFINE DO_ERR  '01'   /* kluda    */

/* Текстовые константы для поля sterr в файле ddopr */
&GLOBAL-DEFINE DOT_OK   ''  
&GLOBAL-DEFINE DOT_ERR  'Kµ­das'  
