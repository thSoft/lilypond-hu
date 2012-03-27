/*
  This file is part of LilyPond, the GNU music typesetter.

  Copyright (C) 2012 Han-Wen Nienhuys <hanwen@xs4all.nl>

  LilyPond is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  LilyPond is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with LilyPond.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "smobs.hh"
#include "ly-smobs.icc"

class Undead {
  DECLARE_SIMPLE_SMOBS (Undead);
  SCM object_;
public:
  SCM object () { return object_; }
  Undead (SCM object = SCM_UNDEFINED) : object_(object) { };
};

SCM
Undead::mark_smob (SCM s)
{
  bool saved = parsed_objects_should_be_dead;
  parsed_objects_should_be_dead = false;
  scm_gc_mark (Undead::unsmob (s)->object ());
  parsed_objects_should_be_dead = saved;
  return SCM_UNDEFINED;
}

int
Undead::print_smob (SCM undead,
		    SCM port,
		    scm_print_state *)
{
  scm_puts ("#<Undead ", port);
  scm_display (Undead::unsmob (undead)->object (), port);
  scm_puts (" >", port);
  return 1;
}

IMPLEMENT_SIMPLE_SMOBS (Undead);
IMPLEMENT_DEFAULT_EQUAL_P (Undead);
IMPLEMENT_TYPE_P (Undead, "ly:undead?")

LY_DEFINE (ly_make_undead, "ly:make-undead",
	   1, 0, 0, (SCM object),
	   "This packages @var{object} in a manner that keeps it from"
	   " triggering \"Parsed object should be dead\" messages.")
{
  Undead undead (object);
  return undead.smobbed_copy ();
}

LY_DEFINE (ly_get_undead, "ly:get-undead",
	   1, 0, 0, (SCM undead),
	   "Get back object from @var{undead}.")
{
  LY_ASSERT_SMOB (Undead, undead, 1);
  return Undead::unsmob (undead)->object ();
}
