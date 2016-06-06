/* rmzcan2u.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Удаление/сторнирование 2-ой проводки внешнего платежа
        разрешается только при совпадение офицера-автора транзакции и желающего ее удалить
 * RUN
        верхнее меню в пунктах платежной системы
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        5-9-3
 * AUTHOR
        22.10.2003 nadejda  - выделено из rmzscan2.p для разделения вызова из 5-9-3 и 5-4
 * BASES
        BANK COMM
 * CHANGES
        16.05.2012 aigul - добавила BASES

*/


{rmzcan2.i
 &run = " find sysc where sysc.sysc = 'supusr' no-lock no-error.
          if (jh.who <> g-ofc) and (not avail sysc or (lookup (g-ofc, sysc.chval) = 0)) then do:
            message ' Вы не имеете права удалять транзакции другого офицера !'.
            pause.
            return.
          end.
        "
}

