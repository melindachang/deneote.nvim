local _ = require('plenary.busted')

local eq, match = assert.are.same, assert.are.match
local Utils = require('deneote.utils')

describe('Utils.map()', function()
  it('procs function on table values', function()
    eq(
      { 2, 4, 6 },
      Utils.map({ 1, 2, 3 }, function(v)
        return v * 2
      end)
    )
  end)
end)

describe('Utils.trim()', function()
  it('trims whitespace, dashes, underscores', function()
    eq('foo', Utils.trim('-_--   foo _ -- __ '))
  end)
end)

describe('Utils.sanitize_filename()', function()
  it('removes illegal characters', function()
    eq('file', Utils.sanitize_filename('|f/i*l:e?<>'))
  end)
end)

describe('Utils.pipe()', function()
  it('applies a single function', function()
    local res = Utils.pipe(5, function(x)
      return x * 2
    end)
    eq(10, res)
  end)

  it('chains multiple functions in order', function()
    local res = Utils.pipe(
      'foo',
      function(s)
        return s .. 'bar'
      end,
      string.upper,
      function(s)
        return s .. '!'
      end
    )
    eq('FOOBAR!', res)
  end)

  it('handles no functions gracefully', function()
    eq('unchanged', Utils.pipe('unchanged'))
  end)

  it('can handle number transformations', function()
    local res = Utils.pipe(2, function(n)
      return n + 3
    end, function(n)
      return n * 4
    end, function(n)
      return n - 1
    end)
    eq(19, res) -- ((2 + 3) * 4) - 1 = 19
  end)

  it('works with functions that return tables', function()
    local res = Utils.pipe(1, function(n)
      return { n, n + 1 }
    end, function(tbl)
      return vim.tbl_map(function(x)
        return x * 10
      end, tbl)
    end)
    eq({ 10, 20 }, res)
  end)
end)

describe('Utils.make_timestamp()', function()
  it('returns string in expected format', function()
    local ts = Utils.make_timestamp()
    match('^%d%d%d%d%d%d%d%dT%d%d%d%d%d%d$', ts)
  end)
end)

describe('Utils.build_file_stem()', function()
  it('handles no-space title and 1 tag', function()
    local ts = Utils.make_timestamp()
    local stem = Utils.build_file_stem(ts, 'foo', 'bar')

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
    local ts = Utils.make_timestamp()
    local stem = Utils.build_file_stem(ts, 'foo bar', 'bar1,bar2')

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
    local ts = Utils.make_timestamp()
    local stem = Utils.build_file_stem(ts, 'foo_bar', 'bar_1,bar2')

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
    local expected_tags = 'bar-1_bar2'

    eq(expected_title, title_part)
    eq(expected_tags, tag_part)
  end)

  it('handles args with breaking dash/underscore patterns', function()
    local ts = Utils.make_timestamp()
    local stem = Utils.build_file_stem(ts, '--foo__bar__', '__bar_1,bar__2')

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
    local expected_tags = 'bar-1_bar-2'

    eq(expected_title, title_part)
    eq(expected_tags, tag_part)
  end)
end)
