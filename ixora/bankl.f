/* bankl.f
 * MODULE
        СПРАВОЧНИКИ
 * DESCRIPTION
        Форма для справочника банков
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-10-1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        20/09/02 nataly - был добавлен признак "Рейтинг" поле bankl.lne
        05.05.2005 u00121 - добавлено поле "Код терминала"
        26/06/2008 madiyar - немножко переделал кривой интерфейс
        25.02.10 marinav - улучшена форма
        19/08/2013 galina - ТЗ1871 добавила поля bankl.smepbank и bankl.smeptrm

*/


         form  " "
                 bankl.bank label "Банк" colon 15
                 bankl.nu label "Участник" colon 41
                 bankl.name label "Название" format "x(60)"  colon 15
                 bankl.addr label "Адрес" colon 15
                 bankl.attn label "Конт.персона" colon 15
                 bankl.tel label "Телефон" colon 15
                 bankl.fax label "FAX" colon 15
                 bankl.tlx label "TELEX" colon 15
                 bankl.lne label "Рейтинг" colon 15
                 in_iso label "Код страны" colon 15
                 bankl.bic label "SWIFT" colon 15 format "x(14)"
                 v-geo label "Гео" colon 15
                 bankl.crbank label "Уч-к клиринга" colon 15
                 bankl.acct label "TCP имя" format "x(45)" colon 15
                 bankl.chipno label "TCP дир." format "x(63)" colon 15
                 bankl.smepbank label "Уч-к СМЭП" colon 15
                 bankl.smeptrm label "TCP имя" format "x(45)" colon 15
                 v-cbankl label "Корр. банк" colon 15 ""
		         bankl.mntrm label "Код банка" colon 15
                 with side-label no-hide column 13
                 width 98 overlay row 6 frame bankl .
