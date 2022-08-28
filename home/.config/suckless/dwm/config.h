/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel size of windows */
static const unsigned int gappx     = 1;        /* gaps size between windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { 
		"UbuntuMono-R.ttf:size=9:antialias=true",
		"DroidSansFallback.ttf:size=9:antialias=true",
	};
static const char dmenufont[]       = "UbuntuMono-R.ttf:size=9:antialias=true";
//background color
static const char col_gray1[]       = "#222222";
//inactive window border color
static const char col_gray2[]       = "#0b2d3e";
//font color
static const char col_gray3[]       = "#bbbbbb";
//current tag and current window font color
static const char col_gray4[]       = "#eeeeee";
//Top bar second color (blue) and active window border color
static const char col_cyan[]        = "#700070";
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
    [SchemeStatus]  = { col_gray3, "#400040",  "#000000"  }, // Statusbar right {text,background,not used but cannot be empty}
    [SchemeTagsSel]  = { col_gray4, "#b000b0",  "#000000"  }, // Tagbar left selected {text,background,not used but cannot be empty}
	[SchemeTagsNorm]  = { col_gray3, "#400040",  "#000000"  }, // Tagbar left unselected {text,background,not used but cannot be empty}
	[SchemeInfoSel]  = { col_gray4, col_cyan,  "#000000"  }, // infobar middle  selected {text,background,not used but cannot be empty}
	[SchemeInfoNorm]  = { col_gray3, "#300030",  "#000000"  }, // infobar middle  unselected {text,background,not used but cannot be empty}

};

/* tagging */
//tag names (upper left)
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9"};

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       0,            1,           -1 }, 
	// { "Librewolf",  NULL,       NULL,       1 << 8,       0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[T]=",      tile },    /* first entry is default */
	{ "[F]",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };
//launches htop
static const char *monitor[] = { "/usr/bin/htop", NULL };
//sets st as the default terminal
static const char *termcmd[]  = { "st", NULL };
//volume controls
static const char *upvol[]   = { "amixer", "-q", "set", "Master", "5%+", "unmute", NULL };
static const char *downvol[] = { "amixer", "-q", "set", "Master", "5%-", "unmute", NULL };
static const char *mutevol[] = { "amixer", "-q", "set", "Master", "toggle", NULL };


// launching apps
static const char *run_librewolf[] = 	{ "librewolf", 			    NULL };
static const char *run_vim[] = 		    { "st", "-e", "nvim",	NULL };
static const char *run_telegram[] = 	{ "telegram", 			    NULL };
static const char *run_firefox[] =      { "firefox",                 NULL };

// brightness controlls
static const char *brightness_up[]  	= { "xbacklight", "-inc", "5", NULL };
static const char *brightness_down[] 	= { "xbacklight", "-dec", "5", NULL };
// locking the screen
static const char *lock[]		= { "slock", NULL };

#include <X11/XF86keysym.h>
#include "shiftview.c"
static char *endx[] = { "/bin/sh", "-c", "endx", "externalpipe", NULL };

// Simplify the T440s Fn combinations
#define TPK_AudioUp XF86XK_AudioRaiseVolume
#define TPK_AudioDown XF86XK_AudioLowerVolume
#define TPK_AudioMute XF86XK_AudioMute
#define TPK_BrightUp XF86XK_MonBrightnessUp
#define TPK_BrightDown XF86XK_MonBrightnessDown


static Key keys[] = {
	/* modifier             key             function        argument */
	{ MODKEY,               XK_d,           spawn,          {.v = dmenucmd } },
	{ MODKEY,	            XK_Return,      spawn,          {.v = termcmd } },
	{ MODKEY,               XK_t,           togglebar,      {0} },
	{ MODKEY,               XK_j,           focusstack,     {.i = +1 } },
	{ MODKEY,               XK_k,           focusstack,     {.i = -1 } },
	{ MODKEY,               XK_i,           incnmaster,     {.i = +1 } },
	{ MODKEY,               XK_u,           incnmaster,     {.i = -1 } },
	{ MODKEY,               XK_h,           setmfact,       {.f = -0.05} },
	{ MODKEY,               XK_l,           setmfact,       {.f = +0.05} },
	{ MODKEY,               XK_z,           zoom,           {0} },
	{ MODKEY,               XK_Tab,         view,           {0} },
	{ MODKEY,	            XK_q,           killclient,     {0} },
	{ MODKEY|ShiftMask,     XK_t,           setlayout,      {.v = &layouts[0]} },
	{ MODKEY|ShiftMask,     XK_f,           setlayout,      {.v = &layouts[1]} },
	{ MODKEY|ShiftMask,     XK_m,           setlayout,      {.v = &layouts[2]} },
	{ MODKEY|ShiftMask,     XK_space,       setlayout,      {0} },
	{ MODKEY|ShiftMask,     XK_space,       togglefloating, {0} },
	{ MODKEY|ShiftMask,		XK_l,           spawn,	        {.v = lock } },
	{ MODKEY,               XK_0,           view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,     XK_0,           tag,            {.ui = ~0 } },
	{ MODKEY,               XK_comma,       focusmon,       {.i = -1 } },
	{ MODKEY,               XK_period,      focusmon,       {.i = +1 } },
	{ MODKEY,               XK_minus,       setgaps,        {.i = -1 } },
	{ MODKEY,               XK_equal,       setgaps,        {.i = +1 } },
	{ MODKEY|ShiftMask,     XK_equal,       setgaps,        {.i = 0  } },
	{ MODKEY|ShiftMask,     XK_comma,       tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,     XK_period,      tagmon,         {.i = +1 } },
	{ MODKEY,              	XK_n,           shiftview,  	{ .i = +1 } },
	{ MODKEY,              	XK_b,           shiftview,      { .i = -1 } },
	{ MODKEY|ShiftMask,		XK_u,           spawn,          { .v = run_vim } },
	{ MODKEY|ShiftMask,		XK_i,           spawn,          { .v = run_firefox } },
	{ MODKEY|ShiftMask,		XK_o,           spawn,          { .v = run_librewolf } },
	{ MODKEY|ShiftMask,		XK_p,           spawn,          { .v = run_telegram } },
   	{ 0,                    TPK_AudioUp,    spawn,	        {.v = upvol   } },
    { 0,                    TPK_AudioDown,  spawn,          {.v = downvol } },
    { 0,                    TPK_AudioMute,	spawn,          {.v = mutevol } },
    { 0, 			        TPK_BrightUp,	spawn,	        {.v = brightness_up } },
	{ 0,				    TPK_BrightDown, spawn,	        {.v = brightness_down } },
	TAGKEYS(                XK_1,                           0)
	TAGKEYS(                XK_2,                           1)
	TAGKEYS(                XK_3,                           2)
	TAGKEYS(                XK_4,                           3)
	TAGKEYS(                XK_5,                           4)
	TAGKEYS(                XK_6,                           5)
	TAGKEYS(                XK_7,                           6)
	TAGKEYS(                XK_8,                           7)
	TAGKEYS(                XK_9,                           8)
	{ MODKEY|ShiftMask,     XK_q,           quit,           {0} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

