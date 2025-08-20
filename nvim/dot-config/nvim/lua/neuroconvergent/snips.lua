-- LuaSnip
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump(1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-H>", function() ls.jump(-1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-E>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end, {silent = true})

ls.add_snippets("cpp", {
	s("main", {
		t({
			"#include <iostream>",
			"",
			"int main() {",
			"		",
		}),
		i(1, "// code here"),
		t({
			"",
			"		return 0;",
			"}",
		}),
	}),

	s("deal2basic", fmt([[
#include <deal.II/grid/tria.h>
#include <deal.II/grid/grid_generator.h>
#include <deal.II/dofs/dof_handler.h>
#include <deal.II/fe/fe_q.h>

using namespace dealii;

template <int dim>
class {}
{{
public:
	{}();
	void run();

private:
	void setup_system();
	void assemble_system();
	void solve();
	void output_results();

	Triangulation<dim> triangulation;
	FE_Q<dim> fe;
	DoFHandler<dim> dof_handler;
}};

template <int dim>
{}<dim>::{}()
	: fe({})
	, dof_handler(triangulation)
{{}}

template <int dim>
void {}<dim>::run()
{{
	setup_system();
	assemble_system();
	solve();
	output_results();
}}

template <int dim>
void {}<dim>::setup_system()
{{
	GridGenerator::{}(triangulation);
	dof_handler.distribute_dofs(fe);
}}

template <int dim>
void {}<dim>::assemble_system()
{{
	// TODO: assemble system
}}

template <int dim>
void {}<dim>::solve()
{{
	// TODO: solve system
}}

template <int dim>
void {}<dim>::output_results()
{{
	// TODO: output results
}}

int main()
{{
	{}<{}> model;
	model.run();
	return 0;
}}
]], {
	i(1, "MyDeal2Model"), -- class name (used multiple times)
	rep(1),							 -- constructor name (same as class)
	rep(1),							 -- class name again (for constructor definition)
	rep(1),							 -- constructor name again
	rep(1),							 -- class name for run method
	rep(1),							 -- class name for setup_system
	i(2, "hyper_cube"),	 -- grid generator
	rep(1),							 -- class name for assemble_system
	rep(1),							 -- class name for solve
	rep(1),							 -- class name for output_results
	rep(1),							 -- class name for main instantiation
	rep(1),							 -- class name (e.g., MyDeal2Model)
	i(3, "2")						 -- dimension
	}))
})
-- Function to get current UTC date/time
local function get_date()
	return os.date("%d %B, %Y")
end

ls.add_snippets("markdown", {
	s("notes", fmt([[
title: "{}"
author: "Sundar Gurumurthy"
institute: "Cranfield University"
topic: "{}"
theme: "Boadilla"
colortheme: "rose"
fonttheme: "professionalfonts"
mainfont: "Iosevka Nerd Font"
fontsize: 12pt
urlcolor: violet
linkcolor: violet
citecolor: maroon
linkstyle: bold
aspectratio: 169
date: {}
locale: en-GB
bibliographyFile: ./bibliography.bib
section-titles: false
toc: true
]], {
		i(1, "MyTitle"),	-- Title
		i(2, "MyTopic"),	-- Topic
		f(get_date),			-- Get date with function
	})
	)
})

-- Function to get current date/time and time zone
local function get_datetime()
	local utc = os.time(os.date("!*t"))
	local localt = os.time()
	local diff = os.difftime(localt, utc)

	local sign = diff >= 0 and "+" or "-"
	diff = math.abs(diff)

	local hours = math.floor(diff / 3600)
	local mins = math.floor((diff % 3600) / 60)

	return os.date("%Y-%m-%d %H:%M:%S") .. string.format(" %s%02d%02d", sign, hours, mins)
end

ls.add_snippets("markdown", {
	s("blogpost", fmt([[
---
layout: post
title: {}
date: {}
description: {}
tags: {}
categories: self, 2025
toc:
	sidebar: left
---
]], {
		i(1, "What I do & why"),										 -- title
		f(get_datetime),														 -- date & time
		i(2, "description"),												 -- description
	i(3, "tag1, tag2")													 -- tags
	}))
})
