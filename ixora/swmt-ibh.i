/* swmt-ibh.i
 * MODULE
        Платежная система
 * DESCRIPTION
        Ввод свифтовых макетов for IBH
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
        31/12/99 koval
 * CHANGES
        09.12.2003 sasco добавил обработку Атырау
        29.03.2005 sasco исправил формирование MT103 вместо MT100
                         добавил формирование 23 поля = "CRED" тип "B"
        02/07/2007 madiyar - немного переделал, чтобы убрать явное упоминание кодов конкретных филиалов
*/

assign comm.swout.rmz = s-remtrz
       comm.swout.cif = usr.cif
       comm.swout.mt  = '103'
       comm.swout.credate = today
       comm.swout.cretime = time
       comm.swout.creuid = userid("bank")
       comm.swout.branch = ourbank.

/* Заполнение временной таблицы для ввода свифтового макета */
def var tmpRNN as char.
def var tmpstr as char.
def var tmpstr3 as char.
def var tmpi as integer.
def buffer tmpswb for comm.swbody.
def var v-engcity as char.

find first comm.swlist where comm.swlist.mt = '103' no-lock no-error.

repeat i=1 to NUM-ENTRIES(comm.swlist.flist):
 /* Найдем поле и его характеристики */
 find first comm.swfield where comm.swfield.swfld = ENTRY (i,comm.swlist.flist) no-lock.

 create comm.swbody.
 assign comm.swbody.rmz     = s-remtrz
        comm.swbody.type    = if lookup('N',comm.swfield.feature)>0 then "N" else ENTRY (1, comm.swfield.feature)
        comm.swbody.swfield = ENTRY (i, comm.swlist.flist)
        comm.swbody.content = ''.

 CASE ENTRY (i, swlist.flist): 
        when '20' then assign comm.swbody.content[1] = s-remtrz + "-S" comm.swbody.type=''.
        when '32' then do:
                        find first bank.crc where bank.crc.crc = bank.remtrz.tcrc no-lock no-error.
                        tmpstr = string(bank.remtrz.payment, ">>>>>>>>>>>>9.99").
                        tmpstr = replace(tmpstr, ".", ",").
                        assign comm.swbody.content[1] = substr(string(year(bank.remtrz.valdt2)), 3, 2)  + "/" + 
                                                 string(month(bank.remtrz.valdt2),"99") + "/" + 
                                                 string(day(bank.remtrz.valdt2), "99")  + " " + 
                                                 bank.crc.code + " " + tmpstr.
        end.
        when '50' then do: 
                        run rus2eng(INPUT-OUTPUT bank.remtrz.ord).
                        tmpi = index(remtrz.ord,"/RNN/").
                        if tmpi > 0 then tmpRNN = substr(bank.remtrz.ord, tmpi , 17).  /* Выделим РНН */
                                    else assign tmpRNN = "/RNN/".

                                tmpstr = replace(trim(bank.remtrz.ord),tmpRNN,"").
                        
                        v-engcity = ''.
                        find first cmp no-lock no-error.
                        if avail cmp then do:
                            find sysc where sysc.sysc = "bnkadr" no-lock no-error.
                            if avail sysc and num-entries(sysc.chval,'|') > 7 then v-engcity = entry(8, sysc.chval, "|").
                        end.
                        if trim(v-engcity) <> '' then tmpstr3 = caps(v-engcity) + ' KAZAKHSTAN'.
                        else tmpstr3 = "KAZAKHSTAN".

                        assign comm.swbody.content[1] = substr(tmpstr,  1,35)
                               comm.swbody.content[2] = substr(tmpstr, 36,35)
                               comm.swbody.content[3] = substr(tmpstr, 71,35)
                               comm.swbody.content[4] = substr(tmpstr,106,35).

                        if comm.swbody.content[2] = "" then assign comm.swbody.content[2] = tmpRNN
                                                                   comm.swbody.content[3] = tmpstr3.
                                                       else assign comm.swbody.content[3] = tmpRNN
                                                                   comm.swbody.content[4] = tmpstr3.
                        comm.swbody.type=''.
        end.
        when '56' then if trim(ib.doc.ibcode[2] + ib.doc.ibname[2] + ib.doc.ibname[3] + ib.doc.ibname[4]) <> "" then
                              assign comm.swbody.type='D'
                              comm.swbody.content[1] = replace(ib.doc.ibcode[1] + ib.doc.ibcode[2],"SWIFT","")
                              comm.swbody.content[2] = ib.doc.ibname[2]
                              comm.swbody.content[3] = ib.doc.ibname[3]
                              comm.swbody.content[4] = ib.doc.ibname[4].

        when '57' then if trim(ib.doc.bbcode[2] + ib.doc.bbname[2] + ib.doc.bbname[3] + ib.doc.bbname[4]) <> "" then
                        assign comm.swbody.type='D'
                              comm.swbody.content[1] = replace(ib.doc.bbcode[1] + ib.doc.bbcode[2],"SWIFT","")
                              comm.swbody.content[2] = ib.doc.bbname[2]
                              comm.swbody.content[3] = ib.doc.bbname[3]
                              comm.swbody.content[4] = ib.doc.bbname[4].

        when '59' then if trim(ib.doc.benacc + ib.doc.benname[2] + ib.doc.benname[3] + ib.doc.benname[4]) <> "" then
                        assign comm.swbody.type=''
                              comm.swbody.content[1] = "/" + ib.doc.benacc
                              comm.swbody.content[2] = ib.doc.benname[2]
                              comm.swbody.content[3] = ib.doc.benname[3]
                              comm.swbody.content[4] = ib.doc.benname[4].
                       else comm.swbody.type=''.

        when '70' then assign comm.swbody.type=''
                              comm.swbody.content[1] = ib.doc.beninfo[1]
                              comm.swbody.content[2] = ib.doc.beninfo[2]
                              comm.swbody.content[3] = ib.doc.beninfo[3]
                              comm.swbody.content[4] = ib.doc.beninfo[4].

        when '71' then assign comm.swbody.type='A'
                              comm.swbody.content[1] = if lookup(bank.remtrz.bi,"BEN,OUR") > 0 then remtrz.bi else "OUR".

        when '72' then comm.swbody.type=''.

        when '23' then assign comm.swbody.type='B'
                              comm.swbody.content[1] = "CRED".

    end case.

/* run rus2eng(INPUT-OUTPUT comm.swbody.content[4]). */

 if comm.swbody.type="N" then comm.swbody.content[1] = "NONE".

end. /*** repeat ***/


/* output through 'MM_CHARSET=windows-1251; mail -s' value('"IBH:VALOUT ' + bank.remtrz.remtrz + '" ps@elexnet.kz').
 put unformatted
 string( today ) + ' ' + string( time, 'HH:MM:SS' )  skip 
 " Валютный перевод (Internet-Office)" skip skip
 ' <' string( usr.id ) '> Nr. ' string( doc.id ) skip ' ' skip
 skip ' '                                                 skip
': '  usr.cif                            skip
': '  usr.contact[1]                     skip
': '  usr.contact[2]                     skip
': '  usr.contact[3]                     skip
': '  usr.contact[4] space usr.contact[5] skip(1) ' '

 "Бенефициар, ИИК "                  
 ib.doc.benacc                       skip
 ib.doc.benname[2]                   skip
 ib.doc.benname[3]                   skip
 ib.doc.benname[4]                   skip(1)

 "Банк бенефициара, БИК "
 ib.doc.bbcode[1] + " " + ib.doc.bbcode[2]      skip
 ib.doc.bbname[2]                   skip
 ib.doc.bbname[3]                   skip
 ib.doc.bbname[4]                   skip(1)

 "Банк-посредник, БИК "                         
 ib.doc.ibcode[1] + " " + ib.doc.ibcode[2]      skip
 ib.doc.ibname[2]                   skip  
 ib.doc.ibname[3]                   skip
 ib.doc.ibname[4]                   skip(1)

 "Детали платежа и информация получателю"       skip
 ib.doc.beninfo[1]                   skip  
 ib.doc.beninfo[2]                   skip  
 ib.doc.beninfo[3]                   skip  
 ib.doc.beninfo[4]                   skip(1)
 "Комиссия "    doc.charge           skip 
 .
 output close. */
