def temp-table tmp-bal
     field acc      as char
     field bank     as char
     field name     as char
     field nostro   as char
     field swift    as char
     field crc      like crc.crc
     field ccrc     as char
     field inbal    as deci
     field inovnt   as deci
     field inprg    as deci
     field dam-amt  as deci
     field cam-amt  as deci
     field lev-amt  as deci
     field prog-amt as deci
     field swid     as integer.     

def var v-crc  as char.
def var v-ovnt as deci.
def var v-str  as char init ''.
def var v-prz  as char init ''.

def var v-swift  as char init ''.
def var v-swift2  as char init ''.

def var v-bank   as char init ''.
def var v-name   as char init ''.

def var v-tot    as decimal.
def var v-totprg as decimal.

def var i      as integer.
def var j      as integer.
def var v-d    as date.
def var v-swid as integer.

for each dfb where dfb.crc <> 1 no-lock break by dfb.crc.

find crc where crc.crc = dfb.crc no-lock no-error.
if avail crc then v-crc = crc.code.

find first bankt where bankt.acc = dfb.dfb 
                       and bankt.aut = true no-lock no-error.
if avail bankt then do:
   v-bank  = bankt.cbank.
   find first bankl where bankl.bank = bankt.cbank no-lock no-error.
   if avail bankl then do:
        v-swift = bankl.bic.
        v-name  = bankl.name.
   end.
   else do:
        v-swift  = "".
        v-name   = "".
   end.
end.
else do:
    next.
end.

v-tot     = dfb.dam[1]  - dfb.cam[1].
v-totprg  = dfb.dam[1]  - dfb.cam[1].
v-swid = 0.
if v-swift  <> "" then do:
     find last swhd where swhd.rdt >= v-clsday 
                           and lookup(swhd.type,"950,940") > 0 
                           and trim(swhd.acc) = dfb.nostroacc
                           and swhd.f64crc    = dfb.crc
                           and swhd.f64amt > 0
                           use-index swhd64 no-lock no-error.
    if avail swhd then do:
        v-tot = swhd.f64amt.
        v-d   = swhd.rdt.
        v-swid = swhd.swid.
    end.
    else do: 
          find last swhd where swhd.rdt >= v-clsday 
                                and lookup(swhd.type,"950,940") > 0 
                                and trim(swhd.acc) = dfb.nostroacc
                                and swhd.f62crc    = dfb.crc
                                and swhd.f62amt > 0
                                use-index swhd62 no-lock no-error.
          if avail swhd then do:
             v-tot = swhd.f62amt.
             v-d   = swhd.rdt.
             v-swid = swhd.swid.
          end.
          else 
             v-tot = dfb.dam[1]  - dfb.cam[1].
    end.

    find last swhd where swhd.rdt >= v-clsday 
                          and lookup(swhd.type,"950,940") > 0 
                          and trim(swhd.acc) = dfb.nostroacc
                          and swhd.f62crc    = dfb.crc
                          and swhd.f62amt > 0
                          use-index swhd62 no-lock no-error.
    if avail swhd and swhd.rdt > v-d  then do:
       v-tot  = swhd.f62amt.
       v-swid = swhd.swid.
    end.
end.

/*if v-tot = 0 then next.*/
/*Определяем Величину Овернайта*/
v-ovnt = 0.

for each swhd where swhd.rdt >= v-clsday and trim(swhd.acc) = dfb.nostroacc no-lock.
     for each swdt where swhd.swid = swdt.swid and swdt.oper = "D" and swdt.rdt >= v-clsday no-lock.
        v-prz = dfb.info[1].
        if index(swdt.ref, v-prz) > 0  or index(swdt.ref2, v-prz) > 0  then do: 
           v-ovnt = swdt.amt.
        end.
     end.
end.

create tmp-bal.
assign tmp-bal.acc   = dfb.dfb
    tmp-bal.bank     = v-bank
    tmp-bal.name     = v-name
    tmp-bal.nostro   = dfb.nostroacc 
    tmp-bal.swift    = v-swift
    tmp-bal.crc      = dfb.crc
    tmp-bal.ccrc     = v-crc
    tmp-bal.inovnt   = v-ovnt
    tmp-bal.inbal    = v-tot
    tmp-bal.inprg    = v-totprg
    tmp-bal.dam-amt  = 0
    tmp-bal.cam-amt  = 0
    tmp-bal.lev-amt  = dfb.nbal
    tmp-bal.prog-amt = 0
    tmp-bal.swid     = v-swid.
end.


