/* user and group to drop privileges to */
static const char *user  = "linet";
static const char *group = "linet";

static const char *colorname[NUMCOLS] = {
	[INIT] =   "black",     /* after initialization */
	[INPUT] =  "#005577",   /* during input */
	[FAILED] = "#CC3333",   /* wrong password */
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 1;

/* default message */
static const char * message = "Look back in your own screen >:(";

/* text color */
static const char * text_color = "#000000";

/* text size (must be a valid size) */
static const char * font_name = "6x13";
