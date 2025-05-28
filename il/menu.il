menuItem_1=hiCreateMenuItem(
?name 'menu_1
?itemText "1"
?callback "function_1"
)
menuItem_2=hiCreateMenuItem(
?name 'menu_2
?itemText "2"
?callback "function_2"
)

hiCreatePulldownMenu(
'trSubMenu
""
list(
menuItem_1
menuItem_2
)
)
sliderMenuItem_A = hiCreateSliderMenuItem(
?name 'menu_A
?itemText "A"
?subMenu trSubMenu
)
separator_1=hiCreateSeparatorMenuItem(
?name 'menu_S
)

menuItem_B= hiCreateMenuItem(
?name 'menu_B
?itemText "B"
?callback "function_B"
)

menuItem_C= hiCreateMenuItem(
?name 'menu_C
?itemText "C"
?callback "function_C"
)

hiCreatePulldownMenu(
'trPulldownMenu
"Menu_my"
list( sliderMenuItem_A menuItem_B  separator_1 menuItem_C )
)

hiInsertBannerMenu((hiGetCIWindow) 'trPulldownMenu (hiGetNumMenus (hiGetCIWindow)));
procedure(add_layout_menu(args)
hiInsertBannerMenu((getCurrentWindow) 'trPulldownMenu (hiGetNumMenus (getCurrentWindow)));
)
deRegUserTriggers("maskLayout"  nil nil 'add_layout_menu)

