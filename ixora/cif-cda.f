/* cif-cda.f
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

form  aaa.aaa aaa.cif
      aaa.regdt format "99/99/9999" label "CD OPEN-DATE"
      vdaytm
      aaa.expdt  format "99/99/9999"
      aaa.rate format "zzzz.9999"
      aaa.opnamt label "DEPOSIT"
      mbal
      v-grduedt  format "99/99/9999"
      /*
      aaa.autoext label "AUTO-EXT"
      aaa.rollover
      aaa.craccnt
      */
      with row 3 centered 1 col overlay
      title " CD Account Setup ".
