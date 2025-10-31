---@module 'plenary.busted'

local eq, match = assert.are.same, assert.are.match
local utils = require('deneote.utils')
local fs = require('deneote.utils.fs')

describe('utils.map()', function()
  it('procs function on table values', function()
    eq(
      { 2, 4, 6 },
      utils.map({ 1, 2, 3 }, function(v)
        return v * 2
      end)
    )
  end)
end)

describe('fs.make_timestamp()', function()
  it('returns string in expected format', function()
    local ts = fs.make_timestamp()
    match('^%d%d%d%d%d%d%d%dT%d%d%d%d%d%d$', ts)
  end)
end)

describe('fs.slug_sanitize()', function()
  it('removes illegal filename characters', function()
    eq('file', fs.slug_sanitize('|f/i*l:e?<>'))
  end)

  it('replaces non-ASCII characters with spaces', function()
    eq(
      'There are no-ASCII     characters     here     ',
      fs.slug_sanitize('There are no-ASCII ： characters ｜ here 😀')
    )
  end)

  it('removes symbols from string', function()
    eq('This-is-test', fs.slug_sanitize('This-is-!@#test'))
  end)
end)

describe('fs.slug_hyphenate()', function()
  it('hyphenates string', function()
    eq('This-is-a-test', fs.slug_hyphenate('__  This is   a    test  __  '))

    eq(
      '!~!!$%^-This-iS-a-tEsT-++-??',
      fs.slug_hyphenate(' ___ !~!!$%^ This iS a tEsT ++ ?? ')
    )
  end)
  it('replaces multiple hyphens with single hyphen', function()
    eq('foo-bar', fs.slug_hyphenate('foo---bar'))
    eq('foo-bar', fs.slug_hyphenate('foo__-bar'))
  end)
  it('trims hyphens from ends of string', function()
    eq('foo', fs.slug_hyphenate('--foo-'))
    eq('foo', fs.slug_hyphenate('- __-foo-__  '))
  end)
end)

describe('fs.sluggify_title()', function()
  it(
    'downcases, hyphenates, de-punctuates, and removes spaces from string',
    function()
      eq(
        'this-is-a-test',
        fs.sluggify_title(' ___ !~!!$%^ This iS a tEsT ++ ?? ')
      )
    end
  )
end)

describe('fs.sluggify_keyword()', function()
  it('downcases, de-punctuates, and removes delimiters from string', function()
    eq('thisisatest', fs.sluggify_keyword(' ___ !~!!$%^ This iS a tEsT ++ ?? '))
  end)
end)

describe('fs.build_file_stem()', function()
  it('handles no-space title and 1 tag', function()
    local ts = fs.make_timestamp()
    local stem = fs.build_file_stem(ts, 'foo', 'bar')

    assert(type(stem) == 'string', 'result should be a string')
    assert(stem:find(ts), 'should contain timestamp')
    assert(stem:find('foo'), 'should contain title')
    assert(stem:find('bar'), 'should contain tag')

    -- parse back the stem
    local id_part, rest = stem:match('^(.-)%-%-(.+)$')
    assert(id_part == ts, 'timestamp/id should match')

    local title_part, tag_part = rest:match('^(.+)__(.*)$')
    assert(title_part, 'should extract title part')
    assert(tag_part, 'should extract tag part')

    local expected_title = 'foo'
    local expected_tags = 'bar'

    eq(title_part, expected_title)
    eq(tag_part, expected_tags)
  end)

  it('handles title with spaces, multiple tags', function()
    local ts = fs.make_timestamp()
    local stem = fs.build_file_stem(ts, 'foo bar', 'bar1,bar2')

    assert(type(stem) == 'string', 'result should be a string')
    assert(stem:find(ts), 'should contain timestamp')
    assert(stem:find('foo'), 'should contain title')
    assert(stem:find('bar'), 'should contain tag')

    -- parse back the stem
    local id_part, rest = stem:match('^(.-)%-%-(.+)$')
    assert(id_part == ts, 'timestamp/id should match')

    local title_part, tag_part = rest:match('^(.+)__(.*)$')
    assert(title_part, 'should extract title part')
    assert(tag_part, 'should extract tag part')

    local expected_title = 'foo-bar'
    local expected_tags = 'bar1_bar2'

    eq(title_part, expected_title)
    eq(tag_part, expected_tags)
  end)

  it('handles args with mismatched dash/underscores', function()
    local ts = fs.make_timestamp()
    local stem = fs.build_file_stem(ts, 'foo_bar', 'bar_1,bar2')

    assert(type(stem) == 'string', 'result should be a string')
    assert(stem:find(ts), 'should contain timestamp')
    assert(stem:find('foo'), 'should contain title')
    assert(stem:find('bar'), 'should contain tag')

    -- parse back the stem
    local id_part, rest = stem:match('^(.-)%-%-(.+)$')
    assert(id_part == ts, 'timestamp/id should match')

    local title_part, tag_part = rest:match('^(.+)__(.*)$')
    assert(title_part, 'should extract title part')
    assert(tag_part, 'should extract tag part')

    local expected_title = 'foo-bar'
    local expected_tags = 'bar1_bar2'

    eq(expected_title, title_part)
    eq(expected_tags, tag_part)
  end)

  it('handles args with breaking dash/underscore patterns', function()
    local ts = fs.make_timestamp()
    local stem = fs.build_file_stem(ts, '--foo__bar__', '__bar_1,bar__2')

    assert(type(stem) == 'string', 'result should be a string')
    assert(stem:find(ts), 'should contain timestamp')
    assert(stem:find('foo'), 'should contain title')
    assert(stem:find('bar'), 'should contain tag')

    -- parse back the stem
    local id_part, rest = stem:match('^(.-)%-%-(.+)$')
    assert(id_part == ts, 'timestamp/id should match')

    local title_part, tag_part = rest:match('^(.+)__(.*)$')
    assert(title_part, 'should extract title part')
    assert(tag_part, 'should extract tag part')

    local expected_title = 'foo-bar'
    local expected_tags = 'bar1_bar2'

    eq(expected_title, title_part)
    eq(expected_tags, tag_part)
  end)
end)
