.. Copyright (c) 2012, Eric Van Dewoestine
   All rights reserved.

   Redistribution and use of this software in source and binary forms, with
   or without modification, are permitted provided that the following
   conditions are met:

   * Redistributions of source code must retain the above
     copyright notice, this list of conditions and the
     following disclaimer.

   * Redistributions in binary form must reproduce the above
     copyright notice, this list of conditions and the
     following disclaimer in the documentation and/or other
     materials provided with the distribution.

   * Neither the name of Eric Van Dewoestine nor the names of its
     contributors may be used to endorse or promote products derived from
     this software without specific prior written permission of
     Eric Van Dewoestine.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

.. _overview:

==================
Overview
==================

Supertab is a vim plugin which allows you to use <Tab> for all your insert
completion needs (:help ins-completion).

Features
--------

- Configurable to suit you needs:

  - Default completion type to use.
  - Prevent <Tab> from completing after/before defined patterns.
  - Close vim's completion preview window when code completion is finished.
  - When using other completion types, you can configure how long to 'remember'
    the current completion type before returning to the default.
  - Don't like using <Tab>? You can also configure a different pair of keys to
    scroll forwards and backwards through completion results.

- Optional improved 'longest' completion support (after typing some characters,
  hitting <Tab> will highlight the next longest match).
- Built in 'context' completion option which chooses the appropriate completion
  type based on the text preceding the cursor.

  - You can also plug in your own functions to determine which completion type
    to use.

- Support for simple completion chaining (falling back to a different
  completion type, keyword completion for example, if omni or user completion
  returns no results).
