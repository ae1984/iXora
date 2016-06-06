/* q-arpacr.f
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

/* q-arpacr.f
*/

form        "НАШ КОД#:" arp.arp skip
            "СЧЕТ   :" arp.gl gl.sname " ВАЛ. :" arp.crc skip
            "ТИП    :" arp.type format "zzz" "      GEO :" arp.geo format "x(3)" 
            "ГРУППА   :" arp.cgr
            " ЗАЛОЖЕН ? :" arp.zalog skip
            "ДАТА РЕГ.:" arp.rdt "   КОН.ДАТА :" arp.duedt skip
            "ОПИСАНИЕ   :" arp.des skip
            "ДЕБЕТ  :" arp.dam[1]        "КРЕДИТ :" arp.cam[1] skip
            "ОСТАТОК:" v-bal skip
            "НАКОПЛ.ВАЛ.  :" arp.ncrc[3] skip
            "НАКОПЛ.БАЛ. :" acrbal  skip
            "ОБЕСПЕЧЕНИЕ:" arp.lonsec   "РИСК :" arp.risk 
            "ДОХОДНОСТЬ К ПОГАШЕНИЮ ::" arp.penny skip
            "КОД КЛ.#    :" arp.cif     "СТАТУС :" arp.sts skip
            with frame arp row 3 centered no-label no-box.
