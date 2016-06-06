/* txmailed.p
 * MODULE
        Налоговые 
 * DESCRIPTION
        Редактирование e-mail налоговых комитетов (TXB00 only)
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
        28/01/04 sasco
 * CHANGES
*/

{txnkmail.i
 &operation = "редактирование"
 &proc = "
          v-mail = taxnk.email.
          update v-mail with frame fm.
          hide frame fm.
          find btaxnk where rowid (btaxnk) = rowid (taxnk) no-error.
          btaxnk.email = v-mail.
         "
}

