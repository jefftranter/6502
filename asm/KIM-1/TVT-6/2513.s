; Code for 2513 character generator ROM

        .org    $0000

; 00
	.byte	$000	;      
	.byte	$00E	;  *** 
	.byte	$011	; *   *
	.byte	$015	; * * *
	.byte	$017	; * ***
	.byte	$016	; * ** 
	.byte	$010	; *    
	.byte	$00F	;  ****
; 01
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$00A	;  * * 
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$01F	; *****
	.byte	$011	; *   *
	.byte	$011	; *   *
; 02
	.byte	$000	;      
	.byte	$01E	; **** 
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$01E	; **** 
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$01E	; **** 
; 03
	.byte	$000	;      
	.byte	$00E	;  *** 
	.byte	$011	; *   *
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$011	; *   *
	.byte	$00E	;  *** 
; 04
	.byte	$000	;      
	.byte	$01E	; **** 
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$01E	; **** 
; 05
	.byte	$000	;      
	.byte	$01F	; *****
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$01E	; **** 
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$01F	; *****
; 06
	.byte	$000	;      
	.byte	$01F	; *****
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$01E	; **** 
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$010	; *    
; 07
	.byte	$000	;      
	.byte	$00F	;  ****
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$013	; *  **
	.byte	$011	; *   *
	.byte	$00F	;  ****
; 08
	.byte	$000	;      
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$01F	; *****
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
; 09
	.byte	$000	;      
	.byte	$00E	;  *** 
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$00E	;  *** 
; 0A
	.byte	$000	;      
	.byte	$001	;     *
	.byte	$001	;     *
	.byte	$001	;     *
	.byte	$001	;     *
	.byte	$001	;     *
	.byte	$011	; *   *
	.byte	$00E	;  *** 
; 0B
	.byte	$000	;      
	.byte	$011	; *   *
	.byte	$012	; *  * 
	.byte	$014	; * *  
	.byte	$018	; **   
	.byte	$014	; * *  
	.byte	$012	; *  * 
	.byte	$011	; *   *
; 0C
	.byte	$000	;      
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$01F	; *****
; 0D
	.byte	$000	;      
	.byte	$011	; *   *
	.byte	$01B	; ** **
	.byte	$015	; * * *
	.byte	$015	; * * *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
; 0E
	.byte	$000	;      
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$019	; **  *
	.byte	$015	; * * *
	.byte	$013	; *  **
	.byte	$011	; *   *
	.byte	$011	; *   *
; 0F
	.byte	$000	;      
	.byte	$00E	;  *** 
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$00E	;  *** 
; 10
	.byte	$000	;      
	.byte	$01E	; **** 
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$01E	; **** 
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$010	; *    
; 11
	.byte	$000	;      
	.byte	$00E	;  *** 
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$015	; * * *
	.byte	$012	; *  * 
	.byte	$00D	;  ** *
; 12
	.byte	$000	;      
	.byte	$01E	; **** 
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$01E	; **** 
	.byte	$014	; * *  
	.byte	$012	; *  * 
	.byte	$011	; *   *
; 13
	.byte	$000	;      
	.byte	$00E	;  *** 
	.byte	$011	; *   *
	.byte	$010	; *    
	.byte	$00E	;  *** 
	.byte	$001	;     *
	.byte	$011	; *   *
	.byte	$00E	;  *** 
; 14
	.byte	$000	;      
	.byte	$01F	; *****
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
; 15
	.byte	$000	;      
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$00E	;  *** 
; 16
	.byte	$000	;      
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$00A	;  * * 
	.byte	$004	;   *  
; 17
	.byte	$000	;      
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$015	; * * *
	.byte	$015	; * * *
	.byte	$01B	; ** **
	.byte	$011	; *   *
; 18
	.byte	$000	;      
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$00A	;  * * 
	.byte	$004	;   *  
	.byte	$00A	;  * * 
	.byte	$011	; *   *
	.byte	$011	; *   *
; 19
	.byte	$000	;      
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$00A	;  * * 
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
; 1A
	.byte	$000	;      
	.byte	$01F	; *****
	.byte	$001	;     *
	.byte	$002	;    * 
	.byte	$004	;   *  
	.byte	$008	;  *   
	.byte	$010	; *    
	.byte	$01F	; *****
; 1B
	.byte	$000	;      
	.byte	$01F	; *****
	.byte	$018	; **   
	.byte	$018	; **   
	.byte	$018	; **   
	.byte	$018	; **   
	.byte	$018	; **   
	.byte	$01F	; *****
; 1C
	.byte	$000	;      
	.byte	$000	;      
	.byte	$010	; *    
	.byte	$008	;  *   
	.byte	$004	;   *  
	.byte	$002	;    * 
	.byte	$001	;     *
	.byte	$000	;      
; 1D
	.byte	$000	;      
	.byte	$01F	; *****
	.byte	$003	;    **
	.byte	$003	;    **
	.byte	$003	;    **
	.byte	$003	;    **
	.byte	$003	;    **
	.byte	$01F	; *****
; 1E
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$00A	;  * * 
	.byte	$011	; *   *
	.byte	$000	;      
	.byte	$000	;      
; 1F
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$01F	; *****
; 20
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
; 21
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$000	;      
	.byte	$004	;   *  
; 22
	.byte	$000	;      
	.byte	$00A	;  * * 
	.byte	$00A	;  * * 
	.byte	$00A	;  * * 
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
; 23
	.byte	$000	;      
	.byte	$00A	;  * * 
	.byte	$00A	;  * * 
	.byte	$01F	; *****
	.byte	$00A	;  * * 
	.byte	$01F	; *****
	.byte	$00A	;  * * 
	.byte	$00A	;  * * 
; 24
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$00F	;  ****
	.byte	$014	; * *  
	.byte	$00E	;  *** 
	.byte	$005	;   * *
	.byte	$01E	; **** 
	.byte	$004	;   *  
; 25
	.byte	$000	;      
	.byte	$018	; **   
	.byte	$019	; **  *
	.byte	$002	;    * 
	.byte	$004	;   *  
	.byte	$008	;  *   
	.byte	$013	; *  **
	.byte	$003	;    **
; 26
	.byte	$000	;      
	.byte	$008	;  *   
	.byte	$014	; * *  
	.byte	$014	; * *  
	.byte	$008	;  *   
	.byte	$015	; * * *
	.byte	$012	; *  * 
	.byte	$00D	;  ** *
; 27
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
; 28
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$008	;  *   
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$010	; *    
	.byte	$008	;  *   
	.byte	$004	;   *  
; 29
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$002	;    * 
	.byte	$001	;     *
	.byte	$001	;     *
	.byte	$001	;     *
	.byte	$002	;    * 
	.byte	$004	;   *  
; 2A
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$015	; * * *
	.byte	$00E	;  *** 
	.byte	$004	;   *  
	.byte	$00E	;  *** 
	.byte	$015	; * * *
	.byte	$004	;   *  
; 2B
	.byte	$000	;      
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$01F	; *****
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$000	;      
; 2C
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$008	;  *   
; 2D
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$01F	; *****
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
; 2E
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$004	;   *  
; 2F
	.byte	$000	;      
	.byte	$000	;      
	.byte	$001	;     *
	.byte	$002	;    * 
	.byte	$004	;   *  
	.byte	$008	;  *   
	.byte	$010	; *    
	.byte	$000	;      
; 30
	.byte	$000	;      
	.byte	$00E	;  *** 
	.byte	$011	; *   *
	.byte	$013	; *  **
	.byte	$015	; * * *
	.byte	$019	; **  *
	.byte	$011	; *   *
	.byte	$00E	;  *** 
; 31
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$00C	;  **  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$00E	;  *** 
; 32
	.byte	$000	;      
	.byte	$00E	;  *** 
	.byte	$011	; *   *
	.byte	$001	;     *
	.byte	$006	;   ** 
	.byte	$008	;  *   
	.byte	$010	; *    
	.byte	$01F	; *****
; 33
	.byte	$000	;      
	.byte	$01F	; *****
	.byte	$001	;     *
	.byte	$002	;    * 
	.byte	$006	;   ** 
	.byte	$001	;     *
	.byte	$011	; *   *
	.byte	$00E	;  *** 
; 34
	.byte	$000	;      
	.byte	$002	;    * 
	.byte	$006	;   ** 
	.byte	$00A	;  * * 
	.byte	$012	; *  * 
	.byte	$01F	; *****
	.byte	$002	;    * 
	.byte	$002	;    * 
; 35
	.byte	$000	;      
	.byte	$01F	; *****
	.byte	$010	; *    
	.byte	$01E	; **** 
	.byte	$001	;     *
	.byte	$001	;     *
	.byte	$011	; *   *
	.byte	$00E	;  *** 
; 36
	.byte	$000	;      
	.byte	$007	;   ***
	.byte	$008	;  *   
	.byte	$010	; *    
	.byte	$01E	; **** 
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$00E	;  *** 
; 37
	.byte	$000	;      
	.byte	$01F	; *****
	.byte	$001	;     *
	.byte	$002	;    * 
	.byte	$004	;   *  
	.byte	$008	;  *   
	.byte	$008	;  *   
	.byte	$008	;  *   
; 38
	.byte	$000	;      
	.byte	$00E	;  *** 
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$00E	;  *** 
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$00E	;  *** 
; 39
	.byte	$000	;      
	.byte	$00E	;  *** 
	.byte	$011	; *   *
	.byte	$011	; *   *
	.byte	$00F	;  ****
	.byte	$001	;     *
	.byte	$002	;    * 
	.byte	$01C	; ***  
; 3A
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$000	;      
	.byte	$000	;      
; 3B
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$000	;      
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$008	;  *   
; 3C
	.byte	$000	;      
	.byte	$002	;    * 
	.byte	$004	;   *  
	.byte	$008	;  *   
	.byte	$010	; *    
	.byte	$008	;  *   
	.byte	$004	;   *  
	.byte	$002	;    * 
; 3D
	.byte	$000	;      
	.byte	$000	;      
	.byte	$000	;      
	.byte	$01F	; *****
	.byte	$000	;      
	.byte	$01F	; *****
	.byte	$000	;      
	.byte	$000	;      
; 3E
	.byte	$000	;      
	.byte	$008	;  *   
	.byte	$004	;   *  
	.byte	$002	;    * 
	.byte	$001	;     *
	.byte	$002	;    * 
	.byte	$004	;   *  
	.byte	$008	;  *   
; 3F
	.byte	$000	;      
	.byte	$00E	;  *** 
	.byte	$011	; *   *
	.byte	$002	;    * 
	.byte	$004	;   *  
	.byte	$004	;   *  
	.byte	$000	;      
	.byte	$004	;   *  
