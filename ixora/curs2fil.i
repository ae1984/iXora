/* curs2fil.i
 * MODULE
        Системные параметры
 * DESCRIPTION
        Копирование курсов валют и истории на филиалы
 * RUN
        &head = таблицы crc, ncrc; &run - позволяет сделать еще какие-нибудь действия
 * CALLER
        bccur2fil.p, nbccur2fil.p
 * SCRIPT

 * INHERIT

 * MENU
        9-1-2-2-1, 9-1-2-2-2
 * BASES
        BANK TXB

 * AUTHOR
        21.11.2002 nadejda
 * CHANGES
        18.09.2003 nadejda - добавила вызов &run
        04/03/08 marinav - перевод цикла на r-branch, изменение адресов
        18/08/2008 id00024 - добавил копирование rate[2-5] на Алматинский филиалнг
        25.08.2009 galina - копируем безанлиные курсы на филиалы
        25.07.2011 aigul - отменила копирование rate[2-5] на Алматинский филиалнг
*/


def input parameter p-crc like bank.{&head}.crc.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
if txb.sysc.chval = "TXB00"  then return.

find bank.{&head} where bank.{&head}.crc = p-crc no-lock no-error.
find txb.{&head} where txb.{&head}.crc = p-crc exclusive-lock no-error.

do transaction on error undo, retry:
    if not avail txb.{&head} then do:
        create txb.{&head}.
        txb.{&head}.crc = p-crc.
    end.
    txb.{&head}.rate[1] = bank.{&head}.rate[1].
    txb.{&head}.des = bank.{&head}.des.
    txb.{&head}.rate[9] = bank.{&head}.rate[9].
    txb.{&head}.decpnt = bank.{&head}.decpnt.
    txb.{&head}.code = bank.{&head}.code.
    txb.{&head}.stn = bank.{&head}.stn.
    txb.{&head}.prefix = bank.{&head}.prefix.
    txb.{&head}.regdt = bank.{&head}.regdt.

    /* ***** 18/08/2008 id00024 ****** */
    /*if txb.sysc.chval = "TXB16"  then do:
        txb.{&head}.rate[2] = bank.{&head}.rate[2].
        txb.{&head}.rate[3] = bank.{&head}.rate[3].
        txb.{&head}.rate[4] = bank.{&head}.rate[4].
        txb.{&head}.rate[5] = bank.{&head}.rate[5].
    end.
    else do:
        txb.{&head}.rate[4] = bank.{&head}.rate[4].
        txb.{&head}.rate[5] = bank.{&head}.rate[5].
    end.*/
    /* *********** */

    find last bank.{&head}his where bank.{&head}his.crc = p-crc and
    bank.{&head}his.rdt = bank.{&head}.regdt no-lock no-error.
    if not avail bank.{&head}his then do:
        message "Ошибка копирования курсов! Не найдена запись bank.{&head}his".
        pause.
        leave.
    end.

    if g-today < today then do:
        find first txb.{&head}his where  txb.{&head}his.crc = txb.{&head}.crc and txb.{&head}his.rdt = g-today and txb.{&head}his.tim = 99999 no-error.
        if avail txb.{&head}his then delete txb.{&head}his.
    end.

    create txb.{&head}his.
    txb.{&head}his.tim = time.
    if g-today < today then txb.{&head}his.tim = 99999 .

    buffer-copy txb.{&head} except txb.{&head}.tim to txb.{&head}his.

    txb.{&head}his.rdt = bank.{&head}his.rdt.
    txb.{&head}his.who = bank.{&head}his.who.
    txb.{&head}his.whn = bank.{&head}his.whn.

    {&run}
end.
