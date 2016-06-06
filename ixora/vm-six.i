
do transaction:

            for each vmtmptbl exclusive-lock.
                delete vmtmptbl.
            end.

            for each tmp-in.
                    create vmtmptbl.
                       vmtmptbl.type     = 1.
                       vmtmptbl.ref      = tmp-in.remtrz.
                       vmtmptbl.obank    = tmp-in.sbank.
                       vmtmptbl.ord      = tmp-in.ord.
                       vmtmptbl.kbank    = tmp-in.rcbank.
                       vmtmptbl.ben      = tmp-in.rbank.
                       vmtmptbl.dtval    = tmp-in.valdt1.
                       vmtmptbl.amt      = tmp-in.amt.
                       vmtmptbl.rtim     = tmp-in.rtim.
                       vmtmptbl.sts      = integer(tmp-in.stsl).
                       vmtmptbl.rem [1]  = string(tmp-in.crc).                   
                       vmtmptbl.rem [2]  = tmp-in.ccrc.                   
            end.

            for each tmp-out.
                 create vmtmptbl.
                    vmtmptbl.type     = 2.
                    vmtmptbl.ref      = tmp-out.remtrz.
                    vmtmptbl.obank    = tmp-out.sbank.
                    vmtmptbl.ord      = tmp-out.ord.
                    vmtmptbl.kbank    = tmp-out.rcbank.
                    vmtmptbl.ben      = tmp-out.rbank.
                    vmtmptbl.dtval    = tmp-out.valdt1.
                    vmtmptbl.amt      = tmp-out.amt.
                    vmtmptbl.rtim     = tmp-out.rtim.
                    vmtmptbl.sts      = integer(tmp-out.stsl).
                    vmtmptbl.rem [1]  = string(tmp-out.crc).                   
                    vmtmptbl.rem [2]  = tmp-out.ccrc.                   

            end.


            for each tmp-out2.
                    create vmtmptbl.
                       vmtmptbl.type     = 3.
                       vmtmptbl.ref      = tmp-out2.remtrz.
                       vmtmptbl.ord      = tmp-out2.ord.
                       vmtmptbl.dtval    = tmp-out2.valdt.
                       vmtmptbl.amt      = tmp-out2.amt.
                       vmtmptbl.rem [1]  = string(tmp-out2.crc).                   
                       vmtmptbl.rem [2]  = tmp-out2.ccrc.                   
                       vmtmptbl.rem [3]  = tmp-out2.pid.                   
                       vmtmptbl.rem [4]  = tmp-out2.dracc.                   
            end.
 
end.

