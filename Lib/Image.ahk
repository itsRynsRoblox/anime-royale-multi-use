#Requires AutoHotkey v2.0

;GUI
global Minimize := "Images\minimizeButton.png" 
global Exitbutton := "Images\exitButton.png" 


;FindText Text and Buttons
AreaText:="|<>*125$38.zk000zzw000Dzz0007zzz001zzzs00Tzsbzzzzy8zzzzzU440Vzs1000Ty8U2E7zW80YVzsV090TzAMGG7rzzzzzy"
ModeCancel:="|<>*134$70.zzzzzzzzzzzzzzzzzzzzzzzzwDzzzzzzzszz0DzzzzzzzXzs0TzzzzzzyDz01zzzzzzzszsDDzzzznz7XzVzw0k3w3k6DyDzU307U60Mzszw0A0A0kEXzXzkkkkkz72DyDz737X7w08zsTwQASATk1XzkMk0lsk33y7z01037X040MDy060ASC0M1Uzy1y8lsy7k73zzzzzzzzzzzzU"
AutoOff:="|<>*80$27.zzzzzzzzzzzzzzzzzzzzzzzzzzzzVsXzk64Ty8F7zXU0TwS03zXmMzyQH7zk6Mzz1nbzzzzzzzzzzzzzzzzzzzzzzzU"
XpText:="|<>*93$35.zzzzzzzzzzzzzzzzzzXzX07y3y203y3s403w3UM07w31kw7w07VwDw0T3sTw1y7Uzw3w01zk7s07z07k0Tw07U1zkQ73zz0s67zy3sADzwDsMTzszslzzzzzzzzzzzzzs"
XpText2:="|<>*134$29.zzzzzzzzzzzzzzzDwk7wDkU3wD303wACC7w0QSDs1swTs7lkzkDU1z0D07w0C0TsMATzVsMzy7sFzyTtXzzzzzzzzzzz"
Disconnect:="|<>*154$122.zznzzzzzzzzzzzzzzzzws7szzzzzzzzzzzzzDzzzC0TDzzzzzzzzzzzznzzznb3zzzzzzzzzzzzzwzzzwtwzzzzzzzzzzzzzzDzzzCT7DVy7kz8T8TkzV0S7sHblnUC0k7k3k3k7U060w0tyQsrXMswMwMstsrD7CCCTbCDlyDDDDDCTATnntXnblnkwzblnnnnU3Dww0NwtwQz3DtwQwwws0nzD06TCTDDwlyDDDDDCTwTnnzXnb3nbADXXnnnnXr3wQSsss1ws3UA1wwwww1s31UD0C1zD1y7kzDDDDkzVsS7sHU"
NextLevel:="|<>*113$31.0000000000000000S1s00TVy00MMVU0AAkk063MMA30wAzlUC7sQk73k2M1Vk1A0Ek0640MQ330A01Vk600ks33yMS1UvABUk0a6sQ0H6AD08z3wzwD0w7w0000000000E"
OpenChat:="|<>*154$30.zzzzzzzzzzw000Ds0007s0007s0007s0007s0007s7zs7s7zs7s0007s0007s0z07s1zU7s0007s0007s0007s0007s0007zs07zzy0Tzzz0zzzzVzzzznzzzzzzzU"
Yen:="|<>*84$8.zzzzaQD3kwDbzs"
Spawn:="|<>*113$63.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw3zzzzzzzzz0Dzzzzzzzzs1zzzzzzzzz7TTzxvzizzsTk7U4QMU7z0S0M0V240zw1k1068FU3zs6C8kk0AQTzslk7701XXz7648ks0QQTs0k307V3XXz0C0Q0wMwQTy3lDl7nbXXzzyDzzzzzzzzzlzzzzzzzzzyDzzzzzzzzznzzzzzzzw"
NextText:="|<>*127$46.T7s000DX6Nk001zABX0006AkyAz77Mv1szzyzXw3XkCTA1k6C0EsU70Mk1U20QE3770S7lUA0S3sz70k1sDXwQ37z0S7lsA0s0s77ks13XkQTXkCTDXzzzzzzzzzzzzzzzs"

LoadingScreen:="|<>*108$182.zzzzzztzzzzzzzzzzzzzlzzzzzzzzzzzzzzzsDzzzzzzzzzzzzsDzzzzzzzzzzy07zy3zzzzzzzzzzzXy3zzzzzzzzzzzU1zzUzzzzzzzzzzzkTUzzzzzzzzzzzs0TzsDzzzzzzzzzzw7sDzzzzzzzzzzyTzzy3zzzzzzzzzzz1zzzzzzzzzzzzzbzzzUzzzzzzzzzzzkTzzzzzzzzzzzztzw7sDy1yCDz0zllk0wSCDzlXzzzzzyTw0S3y0D00zU3s0806300zk0Tzzzzzby03Uz01k07k0S0201Uk07s07zzzzztz00MDU0A01s03U0U0MA00w01zzzzzyTkQ63k4300A00M0A06300C00TzzzzzbsDVUw7UkC30s61zkTUkC1UM7zzzzzVy3kMD1sA7UET1Uzw7sA7kMD1zzzzzwTU063k031w47kMDz1y31w63kTzzzzzbs03Uw01kS11w63zkTUkT1Uw7zzzzzty3zsD1zw30kC1Uzw7sA7kM61zzzzzyTkzy0kDj00A00MDz0S31w600MQC7zzbw03U601k07U0C3zk3UkT1k0631VzztzU0w1U0A01w07Uzy0sA7kS01UkMDzyTw0D0Q0701zU3sDzUC31w7k0MA67zzzzU7wDk1kNzw1z3zy3ksz3zg67Xlzzzzzzzzzzw7zzzzzzzzzzzzzz1zzzzzzzzzzzzzz1zzzzzzzzzzzzzXUTzzzzzzzzzzzzzkTzzzzzzzzzzzzk0Dzzzzzzzzzzzzzw7zzzzzzzzzzzzw03zzzzzzzzzzzzzz1zzzzzzzzzzzzzU1zzzzzzzzzzzzzzkTzzzzzzzzzzzzw1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy"
;New UI
Results:="|<>*125$82.zzzzzzzzzzzzzzzzzzzzzzzzyTzz0Tzzzzzzzzkzzw0Tzzzzzzzz3zzk0zzzzzzzzwDzz33zzzzzzzzkzzwSD0nXbVAFk30zlsM06AA0E6083z7304EFU10E0WDw0AQE1644D227zk1k100MsFwQ83z060603XV7lkk7wQATs8C44T23kTlsk1kVs0Fw081z7VU737k17s0UDwTD0yQzVATkb1zzzzzzzzzzzzzzs"
Teleports:="|<>*105$46.zy00Mzzzzk01Xzzzz002Dzzzy008zzzsTzzzrzy0zzzyDzsVzxwstz74N1V13wSFU040Dlt608MkzX4E1UX1y0844207w0kEMQEzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs"
Story:="|<>*150$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU031s6DDzzzy1041k6QTzzzwznllbANzzzzszbbnCQ3zzzzkDCDaMwDzzzzsCQTA1szzzzzwQwyM3tzzzzyMtsEn7nzzzzw3ns3bDbzzzzwDbsDCTDzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
UpgradeText:="|<>*91$83.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzztzz3zVyT7zzzzzXzw613sSDzzzzz7zss3bkwTzzzzyDzlk3DVszzjjzUQzX36T3k1U0A20UT6CAz7U300E410SAQNyD1UM761UMwMsnwQ30lCA303wslbs0U82S0U9ztk7Ds30k4w10EDnkCTwCLu9wLZkTbkwzzwzgzzzzzzDztzzty1zzzzzyDzXzzny7zzzzzwTy7zzzzzzzzzzzzzzzzzzzzzzzzzzzy"
VictoryText:="|<>*82$126.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzlzwADw0w003s3z03wTwTzUzs07k08001U0y00sDsDz0zs07U0000100S00E7kDzUTs0700400000C0087kDzUTk860040000060083UDzkDk860MDw3w0U200410TzkDUM41yTw3s3s21s610zzs7UM43zzw3s7w21s600zzs70s43zzw3s7y21s701zzw30s47zzw3sDy2007U3zzw31s47zzw3sDy200DU3zzy21s47zzw3sDy200Dk7zzy03s43zzw3s7w200TsDzzz03s41yTw3s3w200TsDzzz07s60sDw3w1k600DsDzzzU7sC00Dw3w0063kDsDzzzUDsD007w3y00C3s7sDzzzkDsDU0Dw3z00S3s7sDzzzkTsDs0Ty7zU0y3wDsDzzzwzwTy1zy7zs3z7wTwTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"
ReturnToLobbyText:="|<>*140$109.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzznwzzzkDzDzzzzbzyTztyTzzs3z7zzzzXzzDzwzDzzwtVViMOTksTbwC7VvryMU0HA43k87nw30k8nz0n8taS1wQntyNUM6NzUE4QnDAyANwyAnAnUznAyCNbaT7AyTaNaNkztW1X0nnDlUT0kA30wTwtVlkNtbssTUQC3UyTzzzzzzzzzzzzzzzzyDzzzzzzzzzzzzzzzzzDzzzzzzzzzzzzzzzzzbzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs"

;Royale UI
UnitManager:="|<>*129$64.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzvjvyxzzzzzzCztlXzzzzzwv634AFl2ATnc0A000001zAa9mEVW40Ty2MbD06009zwNXAxUO487zzzzzzzzozzzzzzzzzz7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy"
ReturnToLobby:="|<>*140$88.3s00003y0M0QQ00TkD000Tw3k3HE011ibDrV0Q9VddaM4nyTzzbbwaTbbzkH8EA23CsOP222N10BYkMAP0dc08Ag446H3aFgmba66EkH9MUCN6sOD223WDgVn6xjvVwAAQSTzzzzzzzzzzzzztzzzzzzzzzzzzzzjzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy"
VoteScreen:="|<>*77$79.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzsCzzxz1zzzzkzw6DzwT0TzzzkDwH7zODWTyzyNby71003Xy00A7XzUU001l20001Xzw8W1lsl42E0nzn4F0syAW180zzs240QD0M0YEQzy3X1D7kS2H8CTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
DefeatText:="|<>*205$99.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzkzzzzzzzzzs0zzzzs7zzzzzzzzy01zzzy0zzzzzwDzzk07zzzUDzzzzzVzzy00TzzwDzzzzzwDzzkw3zzzVzzzzzzXzzw7kDsTsDy7zzzsDzzVz1w0w0D0Ds8Q0DzwDwD03U1k0y03U1zzVzVk0Q0A07U0M0TzwDwA73U31ks07U7zz1z31sS7kS63Uy7zzsTsM03ky00ky7kzzz3y700y7k0C7ky7zzsTUsDzky3zkw7lzzy3UD3zyDkzy21w7zzk03s4DVy13k0DUDzy00z01wDk0S01w1zzk0Tw0DVz03s0DkDzy0Tzk3wTw0zlXz3zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
UnitExistence:="|<>*151$45.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy0TzzzrzyTzzzwzznmpklXzyQ6440DznArA4bzyNatUAzznUrUZXzyS6y6CTzzzzgzzzzzzwDzzzzzzzzzzzzzzzzzzzzzzzzw"
Upgrade:="|<>*94$47.zzzzzzzzzzzzzzTznbzzzyTzbDzzzwzzC0k0113yQ100003wMMENVUDw464s81TwMSBkkkzznuTzzzzzrlzzzzk"
MaxUpgraded:="|<>*97$85.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyzyTzzzXztnzzzzDy1nnb1zwtzzzzbz8llt4zyQ1U0227Y0sS6TzC0U0001m0MD7Dzb333AA1t9A31bzs8A9kE2wboNaHzyAD6sMMSPuSb9zzzTHzzzzjzzzwzzzjXzzzznzzzwTzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
SelectMode:="|<>*169$51.nzwzzz00zlzvDzw3ls3yNzzUH70TvDzzWQtzztzzzlr7w3D0s82s70Nk600LkMlCAFiCDV09k2TH3C87C1nuMMV7sly1lV0M320s66A6kQQ7VsUTXyyzbsw007U00X0000Q00000U"
