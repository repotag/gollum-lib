# ~*~ encoding: utf-8 ~*~
require File.expand_path("../helper", __FILE__)
require File.expand_path("../wiki_factory", __FILE__)

input = <<-EOF
---
# First header on line 9
Lala
## Second header on line 18
---

# First header on line 9

# First header [on](http://www.google.com) line 9

Some text.

```ruby
A code block
# With a nasty header in it!
For you
```

## Second header on line 19

More text.
EOF

context "Sourcemaps" do
  setup do
    @wiki, @path, @teardown = WikiFactory.create 'examples/test.git'
  end

  teardown do
    @teardown.call
  end

  test "formats page from Wiki#pages" do
    @wiki.write_page("Bilbo", :markdown, input, commit_details)
    puts "full sourcemap #{@wiki.pages[0].sourcemap.inspect}"
    assert_equal @wiki.pages[0].sourcemap['#first-header-on-line-9'], 7.to_s
    assert_equal @wiki.pages[0].sourcemap['#1-first-header-on-line-9'], 9.to_s
    assert_equal @wiki.pages[0].sourcemap['#first-header-on-line-9_second-header-on-line-19'], 19.to_s
  end

end

