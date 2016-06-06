/* dfbedit.p
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
        18/10/04 tsoy добавил статус       
        15/04/2009 galina - генерация 20-тизначного счета
        16.04.2009 galina - перекомпеляция
                            если номер ввели вручную, присваиваем этот номер счета
        17.04.2009 galina -  подвинула форму cmd на 10 позиций вправо      
        20.04.2009 galina - яно указала ширину фрейма slct                      
*/

/* dfbedit.p
*/

/*{mainhead.i NAENT}    DUE FROM BANK REGISTER  */
{mainhead.i NAFILE0}    /* DUE FROM BANK REGISTER  */

def var vans as log init false format "да/нет".
def var cmd as char form "x(13)" extent 5
  initial ["СЛЕДУЮЩИЙ","НАСТРОЙКА","РЕДАКТИРОВАТЬ","УДАЛИТЬ","ВЫХОД"].

def var vyst like jl.dam.
def var vydr like vyst.
def var vycr like vyst.
def var vmst like vyst.
def var vmdr like vyst.
def var vmcr like vyst.
def var vtst like vyst.
def var vtdr like vyst.
def var vtcr like vyst.
def var vyas like vyst.
def var vmas like vyst.
def var vyir like vyst.
def var vyip like vyst.
def var vmir like vyst.
def var vmip like vyst.
def var vbal like vyst.

def var v-acc as char.
def buffer b-dfb for dfb.
def var v-dfb like dfb.dfb.
form cmd with width 15 col 92 row 3 no-label frame slct overlay top-only.

def var v-subcode as char.
def var v-subname as char.

loop:
repeat:

  {dfbedit.f}

  view frame dfb.
  
  update v-dfb with frame dfb.
  find first dfb where dfb.dfb = v-dfb no-error.
  if not available dfb then do:
     bell.
     {mesg.i 1807} update vans.
     if vans eq false then next.
        hide message.
        create dfb.
        dfb.rdt = g-today.
        dfb.who = g-ofc.
        dfb.whn = g-today.
        
        update dfb.crc dfb.gl with frame dfb.
        if dfb.crc > 0 and dfb.gl > 0 then do:
          if v-dfb = "" then  run acc_gen(input dfb.gl,string(dfb.crc),'','',false, output v-dfb).
          dfb.dfb = v-dfb.
          
          find sub-cod where sub-cod.sub = "dfb" and sub-cod.acc = dfb.dfb and sub-cod.d-cod = "clsa" no-error.

          if avail sub-cod then do:
     
             find codfr where codfr.codfr = "clsa" and codfr.code = sub-cod.ccode no-lock no-error.
             v-subcode = sub-cod.ccode.
             v-subname = codfr.name[1].

          end. 
          else do:

             create sub-cod.
                sub-cod.sub   = "dfb".
                sub-cod.acc   = dfb.dfb.
                sub-cod.d-cod = "clsa".
                sub-cod.ccode = "msc".

            find codfr where codfr.codfr = "clsa" and codfr.code = sub-cod.ccode no-lock no-error.
            v-subcode = sub-cod.ccode.
            v-subname = codfr.name[1].

          end.
          display v-dfb v-subcode v-subname with frame dfb.
        end.  

      /*  create sub-cod.
           sub-cod.sub   = "dfb".
           sub-cod.acc   = dfb.dfb.
           sub-cod.d-cod = "clsa".
           sub-cod.ccode = "msc".*/

        vans = false.
     end.

     vyst = dfb.ydam[1] - dfb.ycam[1].   /* year start */
     vydr = dfb.dam[1]  - dfb.ydam[1].   /* YTD this year */
     vycr = dfb.cam[1]  - dfb.ycam[1].   /* YTD this year */
     vmst = dfb.mdam[1] - dfb.mcam[1].   /* month start */
     vmdr = dfb.dam[1]  - dfb.mdam[1].   /* MTD this month */
     vmcr = dfb.cam[1]  - dfb.mcam[1].   /* MTD this month */
     vtst = dfb.dam[3]  - dfb.cam[3].    /* yesterday balalce */
     vtdr = dfb.dam[1]  - dfb.dam[3].    /* today Debit */
     vtcr = dfb.cam[1]  - dfb.cam[3].    /* today Credit */
     vbal = dfb.dam[1]  - dfb.cam[1].    /* today balance */
     vyas = dfb.dam[5]  - dfb.ydam[5].   /* This yr accum total */
     vmas = dfb.mdam[5] - dfb.ydam[5].   /* This month accum total */
     
   /*  find sub-cod where sub-cod.sub = "dfb" and sub-cod.acc = dfb.dfb and sub-cod.d-cod = "clsa" no-error.

     if avail sub-cod then do:
     
          find codfr where codfr.codfr = "clsa" and codfr.code = sub-cod.ccode no-lock no-error.
          v-subcode = sub-cod.ccode.
          v-subname = codfr.name[1].

     end. else do:

           create sub-cod.
                sub-cod.sub   = "dfb".
                sub-cod.acc   = dfb.dfb.
                sub-cod.d-cod = "clsa".
                sub-cod.ccode = "msc".

          find codfr where codfr.codfr = "clsa" and codfr.code = sub-cod.ccode no-lock no-error.
          v-subcode = sub-cod.ccode.
          v-subname = codfr.name[1].

     end.*/

     display
        v-dfb
        dfb.gl
        dfb.crc
        dfb.name
        dfb.addr[1]
        dfb.addr[2]
        dfb.addr[3]
        dfb.tel
        dfb.fax
        dfb.tlx dfb.ref
        dfb.intrate
        dfb.crline
        vyst
        vydr
        vycr
        vmst
        vmdr
        vmcr
        vtst
        vtdr
        vtcr
        vbal
        vyas
        vmas
        v-subcode 
        v-subname
/*
        vyir
        vyip
        vmir
        vmip
*/
        with frame dfb.
     repeat:
        pause 0.
        display cmd auto-return with frame slct.
        choose field cmd with frame slct.
        if frame-value eq "СЛЕДУЮЩИЙ" then leave.
        else if frame-value eq "УДАЛИТЬ" then do:
           {mesg.i 0970} update vans.
           if vans then do:
             find first sub-cod where sub-cod.sub = "dfb" and sub-cod.acc = dfb.dfb and sub-cod.d-cod = "clsa" no-error.
             if avail sub-cod then delete sub-cod.
             delete dfb.
           end.  
           hide message.
           v-dfb = ''.
           clear frame dfb all.
           vans = false.
           next loop.
        end.
        else if frame-value eq "НАСТРОЙКА" then do:
        update
           dfb.crc
           dfb.gl with frame dfb.

        if dfb.crc > 0 and dfb.gl > 0 then do:
          if dfb.dfb = "" then run acc_gen(input dfb.gl,string(dfb.crc),'','',false, output dfb.dfb).
          find sub-cod where sub-cod.sub = "dfb" and sub-cod.acc = dfb.dfb and sub-cod.d-cod = "clsa" no-error.

          if avail sub-cod then do:
     
             find codfr where codfr.codfr = "clsa" and codfr.code = sub-cod.ccode no-lock no-error.
             v-subcode = sub-cod.ccode.
             v-subname = codfr.name[1].

          end. 
          else do:

             create sub-cod.
                sub-cod.sub   = "dfb".
                sub-cod.acc   = dfb.dfb.
                sub-cod.d-cod = "clsa".
                sub-cod.ccode = "msc".

            find codfr where codfr.codfr = "clsa" and codfr.code = sub-cod.ccode no-lock no-error.
            v-subcode = sub-cod.ccode.
            v-subname = codfr.name[1].

          end.
          display v-dfb v-subcode v-subname with frame dfb.
         
        end.  
           
        update           
           dfb.name
           dfb.addr[1]
           dfb.addr[2]
           dfb.addr[3]
           with frame dfb.
        
        
        view frame dfb1.
        display dfb.duedt dfb.zalog dfb.lonsec dfb.risk dfb.penny dfb.bank
            with frame dfb1.
        /*
        on "help" of dfb.bank do:
            run helpbank.
        end.
        */
        on "help" of dfb.bank in frame dfb1 do:
            {itemlist.i
             &defvar = " "
             &file = "bankl"
             &where = "true"
             &frame = "row 5 centered scroll 1 12 down overlay "
             &form = "bankl.bank bankl.name"
             &index = "bank"
             &chkey = "bank"
             &chtype = "string"
             &flddisp = "bankl.bank bankl.name"
             &funadd = "if frame-value = "" "" then do:
                        {imesg.i 9205}.
                        pause 1.
                        next.
                        end."
             &set = "2"}
             frame-value = frame-value.
             dfb.bank = frame-value.
             display dfb.bank with frame dfb1.
        end.

        update dfb.bank validate(can-find(bankl where 
           bankl.bank = dfb.bank), "" ) with frame dfb1.
        update dfb.duedt with frame dfb1.
        update dfb.zalog with frame dfb1.
        update dfb.lonsec with frame dfb1.
        update dfb.risk with frame dfb1.
        update dfb.penny
        with frame dfb1.
        hide frame dfb1.
        
        update   
           dfb.tel
           dfb.fax
           dfb.tlx
           dfb.ref
           v-subcode 
           with frame dfb.

           find sub-cod where sub-cod.sub = "dfb" and sub-cod.acc = dfb.dfb and sub-cod.d-cod = "clsa" no-error.

           if avail sub-cod then do:
                sub-cod.ccode = v-subcode. 
           end. 
        end.
     else if frame-value eq "РЕДАКТИРОВАТЬ" then do:
        update
           dfb.intrate
           dfb.crline
           vyst      /* if neg then and "L" then problem */
           vydr
           vycr
           vmst
           vmdr
           vmcr
           vtst
           vtdr   
           vtcr
           with frame dfb.
        
        find gl where gl.gl eq dfb.gl.
        if gl.type eq "A" then do:
           dfb.ydam[1] = vyst.   /* year start */
           dfb.ycam[1] = 0.
           end.
        else do:
           if vyst lt 0 then vyst = - vyst.  /* modification */
           dfb.ycam[1] = vyst.  /* year start,  here problem */
           dfb.ydam[1] = 0.
           end.
        dfb.dam[1]  = dfb.ydam[1] + vydr.
        dfb.cam[1]  = dfb.ycam[1] + vycr.
        dfb.mdam[1] = dfb.dam[1]  - vmdr.
        dfb.mcam[1] = dfb.cam[1]  - vmcr.
        dfb.dam[3]  = dfb.dam[1]  - vtdr.
        dfb.cam[3]  = dfb.cam[1]  - vtcr.
        /*
        dfb.dam[5]  = dfb.ydam[5] + vyas.
        dfb.mdam[5] = dfb.ydam[5] + vmas.
        dfb.cam[2]  = dfb.ycam[2] + vyir.
        dfb.dam[2]  = dfb.ydam[2] + vyip.
        dfb.mcam[2] = dfb.ycam[2] + vmir.
        dfb.mdam[2] = dfb.ydam[2] + vmip.
        */
        end.
     else if frame-value eq "ВЫХОД" then return.
     end.
 hide frame slct.
 end.
