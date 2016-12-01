; Copyright (C) 2012-2016 by Jeff Tranter <tranter@pobox.com>
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

; Delay routine. Taken from the Apple II ROM routine at $FCA8.
; Delay in clock cycles is 13 + 27/2 * A + 5/2 * A * A
; Changes registers: A
; Also see: chapter 3 of "Assembly Cookbook for the Apple II/IIe"
; for more details on how to use it.

WAIT:    SEC
WAIT2:   PHA
WAIT3:   SBC   #$01
         BNE   WAIT3
         PLA              ; (13+27/2*A+5/2*A*A)
         SBC   #$01
         BNE   WAIT2
         RTS
